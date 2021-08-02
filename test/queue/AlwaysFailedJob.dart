import 'package:flutter/cupertino.dart';
import 'package:flutter_queue/JobHandler.dart';
import 'package:flutter_queue/QueueJob.dart';

class AlwaysFailedJob extends JobHandler {
  static String name = 'always_failed';
  VoidCallback onRetry;

  AlwaysFailedJob({required this.onRetry});

  @override
  Future<void> handle(QueueJob job) {
    onRetry();
    throw new Exception("failed");
  }


}