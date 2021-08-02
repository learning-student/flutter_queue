import 'dart:convert';

import 'package:flutter_queue/JobHandler.dart';
import 'package:flutter_queue/QueueJob.dart';
import 'package:flutter_queue/RetryLater.dart';
import 'package:flutter_queue/flutter_queue.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'queue/AlwaysFailedJob.dart';
import 'queue/DelayedJobHandler.dart';
import 'queue/FailedJobHandler.dart';
import 'queue/OnAddedTest.dart';
import 'queue/TestJobHandler.dart';

Map<String, JobHandler> jobs = {TestJobHandler.name: TestJobHandler()};

Future<QueueService> createQueueService() async {
  SharedPreferences.setMockInitialValues({}); //set values here
  SharedPreferences pref = await SharedPreferences.getInstance();

  return QueueService(sharedPreferences: pref, registeredJobs: jobs);
}

void main() {
  test('should register jobs correctly', () async {
    final queueService = await createQueueService();
    expect(queueService.registeredJobs.length, 1);
  });

  test('Queue service jobs should add to shared prefences and to list',
      () async {
    final queueService = await createQueueService();
    final pref = queueService.sharedPreferences;

    queueService.addJob(QueueJob(name: TestJobHandler.name, payload: null));

    expect(queueService.jobs.length, 1);
    dynamic jobs = pref.getString('jobs');

    expect(jobs is String, isTrue);

    List<dynamic> jobList = jsonDecode(jobs);

    expect(jobList.length, 1);
  });

  test('Should initialize jobs correctly', () async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.remove('jobs');
    final queueService =
        QueueService(sharedPreferences: pref, registeredJobs: jobs);
    queueService.addJob(QueueJob(payload: 'test', name: TestJobHandler.name));
    SharedPreferences pref1 = await SharedPreferences.getInstance();

    final queueService1 =
        QueueService(registeredJobs: jobs, sharedPreferences: pref1);
    List<QueueJob> jobList = queueService1.jobs;

    expect(jobList.length > 0, isTrue, reason: "joblist is empty");
  });

  test('should execute a job perfectly', () async {
    final queueService = await createQueueService();
    queueService.addJob(QueueJob(payload: 'test', name: TestJobHandler.name));
    await queueService.startJobs();

    expect(queueService.jobs.length == 0, isTrue,
        reason: "job didn't executed");
  });

  test('must not execute the job if check fails', () async {
    final queueService = await createQueueService();
    queueService.registeredJobs = {
      TestJobHandler.name: TestJobHandler(shouldExecute: false)
    };

    queueService.addJob(QueueJob(payload: 'test', name: TestJobHandler.name));
    await queueService.startJobs();

    expect(queueService.jobs.length > 0, isTrue, reason: "job did  execute");
  });

  test('should only execute 3 jobs of total 5', () async {
    final queueService = await createQueueService();

    queueService.addJob(QueueJob(payload: 'test', name: TestJobHandler.name));
    queueService.addJob(QueueJob(payload: 'test', name: TestJobHandler.name));
    queueService.addJob(QueueJob(payload: 'test', name: TestJobHandler.name));
    queueService.addJob(QueueJob(payload: 'test', name: TestJobHandler.name));
    queueService.addJob(QueueJob(payload: 'test', name: TestJobHandler.name));

    await queueService.startJobs(executeJobs: 3);

    expect(queueService.jobs.length == 2, isTrue,
        reason: "more or less jobs executed");
  });

  test('should only execute first 2 of 5 totals', () async {
    final queueService = await createQueueService();

    queueService.registeredJobs = {'delayed': DelayedJobHandler()};

    queueService
        .addJob(QueueJob(payload: 'delayed', name: DelayedJobHandler.name));
    queueService
        .addJob(QueueJob(payload: 'delayed', name: DelayedJobHandler.name));
    queueService
        .addJob(QueueJob(payload: 'delayed', name: DelayedJobHandler.name));
    queueService
        .addJob(QueueJob(payload: 'delayed', name: DelayedJobHandler.name));
    queueService
        .addJob(QueueJob(payload: 'delayed', name: DelayedJobHandler.name));

    await queueService.startJobs(timeout: 1500);

    expect(queueService.jobs.length == 3, isTrue,
        reason: "timeout was 2000 and more then 2 jobs executed");
  });

  test('should only execute first 3 of 5 totals', () async {
    final queueService = await createQueueService();

    queueService.registeredJobs = {'delayed': DelayedJobHandler()};

    queueService
        .addJob(QueueJob(payload: 'delayed', name: DelayedJobHandler.name));
    queueService
        .addJob(QueueJob(payload: 'delayed', name: DelayedJobHandler.name));
    queueService
        .addJob(QueueJob(payload: 'delayed', name: DelayedJobHandler.name));
    queueService
        .addJob(QueueJob(payload: 'delayed', name: DelayedJobHandler.name));
    queueService
        .addJob(QueueJob(payload: 'delayed', name: DelayedJobHandler.name));

    await queueService.startJobs(timeout: 3000);

    expect(queueService.jobs.length == 2, isTrue,
        reason: "timeout was 2000 and more then 2 jobs executed");
  });

  test('failed job must not be deleted', () async {
    final queueService = await createQueueService();
    queueService.registeredJobs = {FailedJobHandler.name: FailedJobHandler()};

    queueService.addJob(QueueJob(payload: 'test', name: FailedJobHandler.name));

    await queueService.startJobs();

    expect(queueService.jobs.length == 1, isTrue,
        reason: "job was failed but still deleted from list");
  });

  test('failed job must retried later after given duration', () async {
    final queueService = await createQueueService();
    queueService.registeredJobs = {FailedJobHandler.name: FailedJobHandler()};

    queueService.addJob(QueueJob(
        payload: 'test',
        name: FailedJobHandler.name,
        retryLater:
            RetryLater.afterDuration(duration: Duration(milliseconds: 1000))));
    await queueService.startJobs();
    expect(queueService.jobs.length == 1, isTrue,
        reason: "job was failed but still deleted from list");

    expect(queueService.jobs.first.waitingForRetry == true, isTrue,
        reason: "job did not marked as waiting for retry");

    await Future.delayed(Duration(milliseconds: 1100));

    expect(queueService.jobs.length == 0, isTrue,
        reason: "job did not called or did not succeed");
  });

  test('job must be called added', () async {
    final queueService = await createQueueService();
    bool called = false;

    queueService.registeredJobs = {
      OnAddedTest.name: OnAddedTest(onAdded: () {
        called = true;
      })
    };

    await queueService.addJob(QueueJob(name: OnAddedTest.name));

    expect(called, isTrue);
  });

  test('jobs must not be retried more the max retry count', () async {
    final queueService = await createQueueService();
    int tryCount = 0;

    queueService.registeredJobs = {
      AlwaysFailedJob.name: AlwaysFailedJob(onRetry: () {
        tryCount += 1;
      })
    };

    queueService.addJob(QueueJob(
        maxRetries: 4,
        name: AlwaysFailedJob.name,
        retryLater:
            RetryLater.afterDuration(duration: Duration(milliseconds: 200))));

    await queueService.startJobs();
    await Future.delayed(Duration(milliseconds: 1200));

    expect(queueService.jobs.length, 0,
        reason: "item did not deleted after retries");

    // 5 = first execution + 4 retries
    expect(tryCount, 5, reason: "item executed more or less than expected");
  });


}
