
import 'package:flutter_queue/JobHandler.dart';
import 'package:flutter_queue/QueueJob.dart';
import 'package:flutter_queue/flutter_queue.dart';

class DelayedJobHandler extends JobHandler {
  static String name = 'delayed';
  @override
  Future<void> handle(QueueJob job, QueueService queueService) async {
    await Future.delayed(Duration(milliseconds: 1000));
  }

}