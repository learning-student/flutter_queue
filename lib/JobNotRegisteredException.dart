class JobNotRegisteredException implements Exception{
  final String jobName;

  JobNotRegisteredException({required this.jobName});
}