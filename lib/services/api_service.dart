import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: "https://uatapi.arthan.ai/arthik/api/v2")
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST("/getOtp")
  Future<dynamic> getOtp(@Body() Map<String, dynamic> mobileNumber);

  @POST("/verifyOtp")
  Future<dynamic> verifyOtp(@Body() Map<String, dynamic> verificationData);

  @GET("/fetchCustId")
  Future<dynamic> fetchCustId(
    @Query('id_type') String idType,
    @Query('id_val') String idVal,
  );

  @GET("/fetchAccountsByCustomerId")
  Future<dynamic> fetchAccountsByCustomerId(
    @Query('customer_id') String customerId,
  );

    @POST("/registerUser")
    Future<dynamic> registerUser(@Body() Map<String, dynamic> userData);

  @POST("/saveArthikAccounts")
  Future<dynamic> saveArthikAccounts(@Body() String userData);
}