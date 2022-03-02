import 'package:flutter_queue/flutter_queue.dart';

import 'QueueJob.dart';

abstract class JobHandler {

  /// the name of the job
  static String jobName = 'queue-job';

  /// this method will be called when the execution has started.
  /// if any error is thrown while execution of this function
  /// the execution of handle will be canceled
  Future<void> onStart(QueueJob job, QueueService queueService) async{
    return;
  }

  /// this method will be called when the execution has ended.
  /// if any error is thrown while execution of this function
  Future<void> onEnd(QueueJob job, QueueService queueService) async {
    return;
  }


  /// this method will handle the execution
  Future<void> handle(QueueJob job, QueueService queueService);

  /// this method will be called before any of the execution
  /// you can check whether you want to run this job at any given point of execution
  /// if false has returned, the job will be postponed to end of the list
  /// after this check [handle] method will be called
  Future<bool> check(QueueJob job, QueueService queueService) async {
    return true;
  }

  /// this method will be called when job added to list first time
  /// you can use this method to execute one time side effects
  /// note: this methods execution will be during [addJob] method and if [startRightAway] is set true
  /// this method will be executed before the job( and before [onStart] and [check])
  Future<void> added(QueueJob job, QueueService queueService) async {
    return;
  }

  /// this method will be called when job removed from regardless of status of execution
  // if failed is true jobs removed after maxRetryCount, this parameter can be used for reinserting job into queue
  // or save it to somewhere else etc.
  Future<void> removed(QueueJob job, bool failed, QueueService queueService) async {
    return;
  }
}