import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import '../models/otp_request_model.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: "https://api.arthan.ai/arthik/api")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST("/getOtp")
  Future<void> getOtp(@Body() OtpRequestModel request);
}
