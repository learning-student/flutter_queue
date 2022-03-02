library flutter_queue;

import 'dart:async';
import 'dart:convert';


import 'package:shared_preferences/shared_preferences.dart';

import 'JobHandler.dart';
import 'JobNotRegisteredException.dart';
import 'QueueJob.dart';
import 'RetryLater.dart';
import 'TimeoutBehavior.dart';

const emptyJobList = <String, JobHandler>{};

class QueueService {
  List<QueueJob> jobs = [];
  static bool working = false;
  int totalExecutedJobs = 0;
  double totalTakenTime = 0;
  Map<String, JobHandler> registeredJobs = {};
  late SharedPreferences sharedPreferences;

  QueueService(
      {required SharedPreferences sharedPreferences,
        this.registeredJobs = emptyJobList}) {
    // initialize jobs from shared_preferences instance

    this.sharedPreferences = sharedPreferences;

    if (sharedPreferences.containsKey('jobs')) {
      List<dynamic> jsonMap = jsonDecode(sharedPreferences.getString('jobs')!);

      jobs = jsonMap.map((e) {
        return initializeJob(e);
      }).toList();
      // map jsons from shared_preferences

    }
  }

  QueueJob initializeJob(Map<String, dynamic> json) {
    String name = json['name'];

    if (!registeredJobs.containsKey(name)) {
      throw new JobNotRegisteredException(jobName: name);
    }

    return QueueJob.fromJson(json);
  }

  Future<void> saveJobs() async {
    await sharedPreferences.setString('jobs', jsonEncode(jobs));
  }

  Future<bool> addJob(QueueJob job) async {
    jobs.add(job);
    await saveJobs();

    /// try to find job handler if not this will throw an exception anyway
    /// and if handler is available we will call handlers on added list
    JobHandler handler = getJobHandler(job);
    await handler.added(job, this);

    if(job.startRightAway ){
      return await executeJob(job);
    }

    return true;
  }

  /// this will destroy job based on the queue jobs' key parameter
  // if failed = true, onRemoved will be called with its second as true
  Future<void> destroyJob(QueueJob job, {bool failed = false}) async {
    jobs = jobs.where((element) {
      return element.key != job.key;
    }).toList();

    await saveJobs();

    /// try to find job handler if not this will throw an exception anyway
    /// and if handler is available we will call handlers on removed from list
    JobHandler handler = getJobHandler(job);
    await handler.removed(job, failed, this);

    return;
  }


  /// When we failed on a job we will try to later
  /// this function mark the job failed and set the lastError property the message
  /// of the last exception
  Future<void> retryJob(QueueJob job, Exception e) async {
    if (job.retryCount <= job.maxRetries) {

      job.lastError = {"message": e.toString()};

      await saveJobs();

      if (job.retryLater.type == RetryTypes.AfterDuration) {
        /// since we will execute job later with Timer function, we need to mark it as waiting
        job.waitingForRetry = true;
        Timer(job.retryLater.duration ?? Duration(milliseconds: 5000), () {
          job.waitingForRetry = false;
          executeJob(job);
        });
      }

      /// we actually don't need to do anything to start the job on  next start
      /// since all the jobs on the startJobs that executed will be deleted and this will remain intact
      if (job.retryLater.type == RetryTypes.NextRestart) {
        return;
      }
    }
  }

  void stopJobs() {
    working = false;
  }

  JobHandler getJobHandler(QueueJob job) {
    if (!registeredJobs.containsKey(job.name)) {
      throw new JobNotRegisteredException(jobName: job.name);
    }

    return registeredJobs[job.name]!;
  }

  Future<bool> executeJob(QueueJob job) async {
    JobHandler handler = getJobHandler(job);
    bool shouldStart = await handler.check(job, this);

    if (shouldStart == false) {
      return false;
    }

    if (job.retryCount >= job.maxRetries) {
      await destroyJob(job, failed: true);
      return false;
    }

    if(job.lastError != null){
      job.retryCount += 1;
      await saveJobs();
    }

    try {
      await handler.onStart(job, this);
    } on Exception catch (e) {
      // there was an error during the execution of onStart, retry later
      await retryJob(job, e);
      return false;
    }

    try {
      await handler.handle(job, this).timeout(job.timeout);

      /// job executed perfectly remove job from the list
      await destroyJob(job);
    } on TimeoutException catch (t) {
      /// job timed out, now we will determine what will happen to this job based on [timeoutBehavior]
      /// if TimeoutBehavior.RetryLater is selected, we will retry later based on [retryLater] propery
      /// if TimeoutBehavior.DestroyJob is selected, we will remove the job as it completed

      if (job.timeoutBehavior == TimeoutBehavior.DestroyJob) {
        await destroyJob(job);
      }

      if (job.timeoutBehavior == TimeoutBehavior.RetryLater) {
        await retryJob(job, t);
      }

      return false;
    } on Exception catch (e) {
      // there was an error during the execution of hanlde, increase the retry count and retry later

      await retryJob(job, e);

      return false;
    }

    try {
      await handler.onEnd(job, this);
    } catch (e) {}

    return true;
  }

  Future<void> startJobs(
      {double executeJobs: double.infinity,
        double timeout: double.infinity}) async {
    if (working == true) {
      return;
    }

    working = true;
    int executedJobs = 0;
    int timeTaken = 0;
    List<QueueJob> slicedJobs = executeJobs == double.infinity
        ? List.from(jobs)
        : jobs.sublist(0, executeJobs.toInt());

    for (QueueJob job in slicedJobs) {
      // if queue stopped working, stop queue
      if (working == false) {
        break;
      }
      // break the loop if we exceeded the limit of execution timeout
      if (timeout != double.infinity && timeTaken > timeout.toInt()) {
        break;
      }

      if (executeJobs != double.infinity &&
          executedJobs >= executeJobs.toInt()) {
        break;
      }

      final stopwatch = Stopwatch()..start();

      bool executed = await executeJob(job);

      if (executed == true) {
        executedJobs += 1;
      }
      timeTaken += stopwatch.elapsedMilliseconds;
    }

    totalTakenTime += timeTaken;
    totalExecutedJobs += executedJobs;
    working = false;
  }
}
