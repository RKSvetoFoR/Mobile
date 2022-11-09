import 'package:dio/dio.dart';
import 'package:eios/oauth/OAuth.dart';

class BearerInterceptor extends Interceptor {
  OAuth oauth;
  Dio dio;

  BearerInterceptor(this.dio, this.oauth);

  @override
  Future onRequest(RequestOptions options) async {
    final token = await oauth.fetchOrRefreshAccessToken();
    print(token.accessToken);
    if (token != null) {
      options.headers.addAll({"Authorization": "Bearer ${token.accessToken}"});
    }
    return options;
  }

  @override
  Future onError(DioError error) async {
    RequestOptions options = error.request;
    if (error.response?.statusCode == 401) {
      final token = await oauth.refreshAccessToken();
      if (token != null) {
        options.headers
            .addAll({"Authorization": "Bearer ${token.accessToken}"});
      }
      return dio.request(options.path);
    }
    return error;
  }
}