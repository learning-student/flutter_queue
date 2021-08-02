
import 'dart:developer';

import 'package:flutter_queue/JobHandler.dart';
import 'package:flutter_queue/QueueJob.dart';
import 'package:json_annotation/json_annotation.dart';


@JsonSerializable()
class TestJobHandler extends JobHandler {
  static String name = "TestJob";
  final bool shouldExecute;

  TestJobHandler({this.shouldExecute = true});

  @override
  Future<void> handle(QueueJob job) async {

    log('here');
  }

  @override
  Future<bool> check(QueueJob job) async {
    return this.shouldExecute;
  }

}
