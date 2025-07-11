import 'package:json_annotation/json_annotation.dart';

part 'otp_request_model.g.dart';

@JsonSerializable()
class OtpRequestModel {
  final String mobileNumber;
  final String deviceId;
  final String appVersion;

  OtpRequestModel({
    required this.mobileNumber,
    required this.deviceId,
    required this.appVersion,
  });

  factory OtpRequestModel.fromJson(Map<String, dynamic> json) =>
      _$OtpRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$OtpRequestModelToJson(this);
}
