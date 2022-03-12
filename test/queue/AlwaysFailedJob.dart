import 'package:flutter/cupertino.dart';
import 'package:flutter_queue/JobHandler.dart';
import 'package:flutter_queue/QueueJob.dart';
import 'package:flutter_queue/flutter_queue.dart';

class AlwaysFailedJob extends JobHandler {
  static String name = 'always_failed';
  VoidCallback onRetry;

  AlwaysFailedJob({required this.onRetry});

  @override
  Future<void> handle(QueueJob job, QueueService queueService) async {
    onRetry();
    throw new Exception("failed");
  }


}