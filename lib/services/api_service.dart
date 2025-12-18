
import 'package:derslig/services/logger_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final _logger = LoggerService.instance;

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
