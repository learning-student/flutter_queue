
import 'dart:developer';

import 'package:flutter_queue/JobHandler.dart';
import 'package:flutter_queue/QueueJob.dart';
import 'package:flutter_queue/flutter_queue.dart';
import 'package:json_annotation/json_annotation.dart';


@JsonSerializable()
class TestJobHandler extends JobHandler {
  static String name = "TestJob";
  final bool shouldExecute;

  TestJobHandler({this.shouldExecute = true});

  @override
  Future<void> handle(QueueJob job, QueueService queueService) async {

    log('here');
  }

  @override
  Future<bool> check(QueueJob job,  QueueService queueService) async {
    return this.shouldExecute;
  }

}
