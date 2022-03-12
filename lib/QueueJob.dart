import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

import 'RetryLater.dart';
import 'TimeoutBehavior.dart';


part 'QueueJob.g.dart';

const nextRestart = RetryLater(type: RetryTypes.NextRestart);

@JsonSerializable()
class QueueJob {
  /// override this name
  final String name;

  /// this will determine the behaviour of retrying if execution of [handle] method is failed
  /// RetryLater.nextRestart will postpone the execution until the restart
  /// RetryLater.afterDuration [duration] will postpone the execution the given duration
  final RetryLater retryLater;

  dynamic payload;

  /// if this is set true, the job execution will start right away
  /// without waiting for startJobs call
  final bool startRightAway;

  /// job timeout in milliseconds
  final Duration timeout;

  /// maximum time to try if execution is failed
  final int maxRetries;

  // this parameters
  DateTime? createdAt;
  /// this parameter will mark the job as waiting for retry
  /// as long as this is set to true, this job won't be executed even if [startJobs] is called
  bool waitingForRetry = false;

  /// current state of retries
  int retryCount = 0;

  late String key;

  Map<String, dynamic>? lastError;

  TimeoutBehavior timeoutBehavior;

  QueueJob(
      {required this.name,
      this.payload,
      this.startRightAway = false,
      this.timeout = const Duration(milliseconds: 5000),
      this.maxRetries = 3,
      this.lastError,
      this.retryLater = nextRestart,
        this.createdAt,
      this.timeoutBehavior = TimeoutBehavior.RetryLater}){
    key = UniqueKey().toString();
    if (this.createdAt == null) {
      this.createdAt = DateTime.now();
    }

  }

  factory QueueJob.fromJson(Map<String, dynamic> json) =>
      _$QueueJobFromJson(json);

  Map<String, dynamic> toJson() => _$QueueJobToJson(this);
}
