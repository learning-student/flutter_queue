
import 'package:flutter_queue/JobHandler.dart';
import 'package:flutter_queue/QueueJob.dart';

class FailedJobHandler extends JobHandler {
  static String name = 'failed';

  @override
  Future<void> handle(QueueJob job) async {

    // this job will be only failed at first try
    if(job.retryCount == 0 ){
      throw new Exception('test failed');
    }
  }

}