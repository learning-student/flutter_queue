import 'package:flutter/cupertino.dart';
import 'package:flutter_queue/JobHandler.dart';
import 'package:flutter_queue/QueueJob.dart';
import 'package:flutter_queue/flutter_queue.dart';

class OnAddedTest extends JobHandler {
  static String name = 'on-added';
  final VoidCallback onAdded;


  OnAddedTest({required this.onAdded});

  @override
  Future<void> handle(QueueJob job, QueueService queueService) async {
     // do nothing for now
  }

  @override
  Future<void> added(QueueJob job, QueueService queueService) async {
    this.onAdded();
  }
}