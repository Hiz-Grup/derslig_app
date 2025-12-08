import 'package:derslig/models/login_response_model.dart';
import 'package:derslig/services/logger_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final _logger = LoggerService.instance;

  Future<LoginResponseModel> login(String email, String password) async {
    const url = 'https://www.derslig.com/api/login';
    final body = {'login': email, 'password': password};

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: body,
      );

      _logger.debugApiLog(
        url: url,
        method: 'POST',
        body: body,
        statusCode: response.statusCode,
        response: response.headers.toString(),
      );

      if (response.statusCode >= 400) {
        _logger.logApiError(
          url: url,
          statusCode: response.statusCode,
          method: 'POST',
          responseBody: response.body,
          requestBody: body,
        );
      }

      RegExp regExpXsrg = RegExp(r'XSRF-TOKEN=(.*?);');
      String xsrfToken = regExpXsrg.firstMatch(response.headers.toString())!.group(1)!;
      RegExp regExpDersligCookie = RegExp(r'derslig_cookie=(.*?);');
      String dersligCookie = regExpDersligCookie.firstMatch(response.headers.toString())!.group(1)!;

      DateTime expireDate = DateTime.now().add(const Duration(days: 60));

      _logger.debugLog('Login başarılı', data: {
        'xsrfToken': '${xsrfToken.substring(0, 20)}...',
        'expireDate': expireDate.toString(),
      });

      return LoginResponseModel(
        xsrfToken: xsrfToken,
        dersligCookie: dersligCookie,
        expireDate: expireDate,
      );
    } catch (e, stackTrace) {
      _logger.logError(
        'Login API hatası',
        error: e,
        stackTrace: stackTrace,
        context: {'url': url},
      );
      rethrow;
    }
  }

  Future<http.Response> postRequest(
    String url,
    Map<String, String> body, {
    Map<String, String>? headers,
  }) async {
    final requestHeaders = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      if (headers != null) ...headers,
    };

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: body,
      );

      _logger.debugApiLog(
        url: url,
        method: 'POST',
        headers: requestHeaders,
        body: body,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode >= 400) {
        _logger.logApiError(
          url: url,
          statusCode: response.statusCode,
          method: 'POST',
          responseBody: response.body,
          requestBody: body,
        );
      }

      return response;
    } catch (e, stackTrace) {
      _logger.logError(
        'POST request hatası',
        error: e,
        stackTrace: stackTrace,
        context: {'url': url, 'body': body.toString()},
      );
      rethrow;
    }
  }

  Future<http.Response> getRequest(
    String url, {
    Map<String, String>? headers,
  }) async {
    final requestHeaders = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      if (headers != null) ...headers,
    };

    try {
      var response = await http.get(
        Uri.parse(url),
        headers: requestHeaders,
      );

      _logger.debugApiLog(
        url: url,
        method: 'GET',
        headers: requestHeaders,
        statusCode: response.statusCode,
        response: response.body,
      );

      if (response.statusCode >= 400) {
        _logger.logApiError(
          url: url,
          statusCode: response.statusCode,
          method: 'GET',
          responseBody: response.body,
        );
      }

      return response;
    } catch (e, stackTrace) {
      _logger.logError(
        'GET request hatası',
        error: e,
        stackTrace: stackTrace,
        context: {'url': url},
      );
      rethrow;
    }
  }
}
