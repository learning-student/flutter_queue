
import 'package:flutter_queue/JobHandler.dart';
import 'package:flutter_queue/QueueJob.dart';

class DelayedJobHandler extends JobHandler {
  static String name = 'delayed';
  @override
  Future<void> handle(QueueJob job) async  {
    await Future.delayed(Duration(milliseconds: 1000));
  }

}