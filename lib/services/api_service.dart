import 'package:retrofit/retrofit.dart' hide Headers;
import 'package:dio/dio.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: "https://uatapi.arthan.ai/arthik/api/v2")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST("/getOtp")
  Future<dynamic> getOtp(@Body() Map<String, dynamic> mobileNumber);
}
