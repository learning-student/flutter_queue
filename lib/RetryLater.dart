import 'package:json_annotation/json_annotation.dart';
part 'RetryLater.g.dart';

enum RetryTypes{
  @JsonValue('AfterDuration') AfterDuration,
  @JsonValue('NextRestart') NextRestart
}

@JsonSerializable()
class RetryLater{
  final RetryTypes type;
  final Duration? duration;

  const RetryLater({required this.type, this.duration});

  factory RetryLater.afterDuration({required Duration duration}){
    return new RetryLater(type: RetryTypes.AfterDuration, duration: duration);
  }

  factory RetryLater.nextRestart(){
    return new RetryLater(type: RetryTypes.NextRestart);
  }

  factory RetryLater.fromJson(Map<String, dynamic> json) => _$RetryLaterFromJson(json);
  Map<String, dynamic> toJson() => _$RetryLaterToJson(this);
}