import 'dart:convert';

import 'package:dio/dio.dart';
//import 'package:eios/oauth/OAuthSecureStorage.dart';

import 'OAuthToken.dart';

typedef OAuthToken OAuthTokenExtractor(Response response);
typedef Future<bool> OAuthTokenValidator(OAuthToken token);

Codec<String, String> stringToBase64 = utf8.fuse(base64);

class OAuth {
  Dio dio;
  String tokenUrl;
  String clientId;
  String clientSecret;
//  OAuthSecureStorage storage;
  OAuthTokenExtractor extractor;
  OAuthTokenValidator validator;

  OAuth(
      {this.tokenUrl,
        this.clientId,
        this.clientSecret,
        this.extractor,
        this.dio,
        this.storage,
        this.validator}) {
    dio = Dio();
    storage = storage;
    extractor = extractor ??
            (res) => OAuthToken(
            accessToken: res.data['access_token'],
            refreshToken: res.data['refresh_token']);
    validator = validator ?? (token) => Future.value(true);
  }

  Future<OAuthToken> requestToken(
      {String grantType,
        String username,
        String password,
        String scope,
        String refreshToken}) async {
    final data = {"grant_type": grantType};

    if (grantType == 'password') {
      data.addAll({"username": username, "password": password});
    } else if (grantType == 'refresh_token') {
      data['refresh_token'] = refreshToken;
    }

    if (scope != null && scope.isNotEmpty) {
      data['scope'] = scope;
    }

    final encodedData = data.entries
        .toList()
        .map((entry) => [
      Uri.encodeComponent(entry.key),
      Uri.encodeComponent(entry.value)
    ].join('='))
        .join('&');

    return dio
        .post(tokenUrl,
        data: encodedData,
        options: Options(
            contentType: 'application/x-www-form-urlencoded',
            headers: {
              "Authorization":
              "Basic ${stringToBase64.encode('$clientId:$clientSecret')}"
            }))
        .then((res) => extractor(res))
        .then((token) => storage.save(token))
        .catchError((err) {
      print(err.response.data);
      print(err.request.headers);
      throw err;
    });
  }

  Future<OAuthToken> fetchOrRefreshAccessToken() async {
    OAuthToken token = await storage.fetch();

    if (token == null) {
      return null;
    }

    if (await this.validator(token)) return token;

    return this.refreshAccessToken();
  }

  Future<OAuthToken> refreshAccessToken() async {
    OAuthToken token = await storage.fetch();

    return this.requestToken(
        grantType: 'refresh_token', refreshToken: token.refreshToken);
  }
}