// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'QueueJob.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QueueJob _$QueueJobFromJson(Map<String, dynamic> json) {
  return QueueJob(
    name: json['name'] as String,
    payload: json['payload'],
    startRightAway: json['startRightAway'] as bool,
    timeout: Duration(microseconds: json['timeout'] as int),
    maxRetries: json['maxRetries'] as int,
    lastError: json['lastError'] as Map<String, dynamic>?,
    retryLater: RetryLater.fromJson(json['retryLater'] as Map<String, dynamic>),
    timeoutBehavior:
        _$enumDecode(_$TimeoutBehaviorEnumMap, json['timeoutBehavior']),
  )
    ..waitingForRetry = json['waitingForRetry'] as bool
    ..retryCount = json['retryCount'] as int
    ..key = json['key'] as String;
}

Map<String, dynamic> _$QueueJobToJson(QueueJob instance) => <String, dynamic>{
      'name': instance.name,
      'retryLater': instance.retryLater,
      'payload': instance.payload,
      'startRightAway': instance.startRightAway,
      'timeout': instance.timeout.inMicroseconds,
      'maxRetries': instance.maxRetries,
      'waitingForRetry': instance.waitingForRetry,
      'retryCount': instance.retryCount,
      'key': instance.key,
      'lastError': instance.lastError,
      'timeoutBehavior': _$TimeoutBehaviorEnumMap[instance.timeoutBehavior],
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$TimeoutBehaviorEnumMap = {
  TimeoutBehavior.RetryLater: 'RetryLater',
  TimeoutBehavior.DestroyJob: 'DestroyJob',
};
