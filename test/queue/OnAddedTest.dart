import 'package:flutter/cupertino.dart';
import 'package:flutter_queue/JobHandler.dart';
import 'package:flutter_queue/QueueJob.dart';

class OnAddedTest extends JobHandler {
  static String name = 'on-added';
  final VoidCallback onAdded;


  OnAddedTest({required this.onAdded});

  @override
  Future<void> handle(QueueJob job) async {
     // do nothing for now
  }

  @override
  Future<void> added(QueueJob job) async {
    this.onAdded();
  }
}