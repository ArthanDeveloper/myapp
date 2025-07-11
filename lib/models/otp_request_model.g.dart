// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'otp_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OtpRequestModel _$OtpRequestModelFromJson(Map<String, dynamic> json) =>
    OtpRequestModel(
      mobileNumber: json['mobileNumber'] as String,
      deviceId: json['deviceId'] as String,
      appVersion: json['appVersion'] as String,
    );

Map<String, dynamic> _$OtpRequestModelToJson(OtpRequestModel instance) =>
    <String, dynamic>{
      'mobileNumber': instance.mobileNumber,
      'deviceId': instance.deviceId,
      'appVersion': instance.appVersion,
    };
