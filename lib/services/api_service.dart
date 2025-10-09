import 'package:myapp/models/loan_details_object.dart';
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
      @Query('id_val') String idVal
      );

  @GET("/fetchAccountsByCustomerId")
  Future<dynamic> fetchAccountsByCustomerId(
      @Query('customer_id') String customerId,);

  @POST("/registerUser")
  Future<dynamic> registerUser(@Body() Map<String, dynamic> userData);

  @POST("/saveArthikAccounts")
  Future<dynamic> saveArthikAccounts(@Body() String userData);

  @POST("/resetMpin")
  Future<dynamic> resetMpin(@Body() Map<String, dynamic> resetData);

  @POST("/updateBiometric")
  Future<dynamic> updateBiometric(@Body() Map<String, dynamic> biometricData);

  @GET("/dashBoard")
  Future<dynamic> getDashBoard(@Query('customerId') String customerId);

  @POST("/auth")
  Future<dynamic> auth(@Body() Map<String, dynamic> verificationData);

  @GET("/getCustomerLoanInfo")
  Future<LoanDetailsObject> getCustomerLoanInfo(@Query('accountId') String accountId);

  @GET("/getAllAccStatement")
  Future<LoanDetailsObject> getAllAccStatement(@Query('accountId') String accountId);

  @GET("/generateReport")
  Future<dynamic> generateReport(
      @Query('reportName') String reportName,
      @Query('accountId_text') String accountIdText,
      @Query('reportOutputType') String reportOutputType,
      );

  @POST("/updatePaymentEntry")
  Future<dynamic> updatePaymentEntry(@Body() Map<String, dynamic> paymentData);
}