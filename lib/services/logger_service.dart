import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();

  static LoggerService get instance => _instance;

  LoggerService._internal();

  static const String sentryDsn =
      'https://eaf1961b6437c11f02ff04b79d58fac2@o4510510395949056.ingest.de.sentry.io/4510510398242896';

  static Future<void> init({required Future<void> Function() appRunner}) async {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.debug = kDebugMode;
        options.diagnosticLevel = SentryLevel.error;

        options.enableAutoSessionTracking = false;
        options.sampleRate = 1.0;
        options.tracesSampleRate = 0.0;

        options.attachViewHierarchy = false;
        options.environment = kDebugMode ? 'development' : 'production';

        options.sendDefaultPii = true;
        options.enableAutoNativeBreadcrumbs = false;
        options.enableAutoPerformanceTracing = false;
        options.attachScreenshot = false;

        options.beforeSend = (event, hint) {
          if (kDebugMode) {
            debugPrint('🚀 [Sentry] Event gönderiliyor: ${event.eventId}');
            if (event.exceptions != null && event.exceptions!.isNotEmpty) {
              debugPrint('   Exception: ${event.exceptions?.first.value}');
            }
          }
          return event;
        };

        options.beforeBreadcrumb = (breadcrumb, hint) {
          return null;
        };
      },
      appRunner: appRunner,
    );
  }

  void debugLog(String message, {Object? data}) {
    if (kDebugMode) {
      debugPrint('📝 $message');
      if (data != null) {
        debugPrint('   Data: $data');
      }
    }
  }

  void debugApiLog({
    required String url,
    String? method,
    Map<String, dynamic>? headers,
    dynamic body,
    dynamic response,
    int? statusCode,
  }) {
    if (kDebugMode) {
      debugPrint('🌐 ══════════════════════════════════════');
      debugPrint('🌐 ${method ?? 'REQUEST'}: $url');
      if (headers != null) debugPrint('🌐 Headers: $headers');
      if (body != null) debugPrint('🌐 Body: $body');
      if (statusCode != null) debugPrint('🌐 Status: $statusCode');
      if (response != null) debugPrint('🌐 Response: $response');
      debugPrint('🌐 ══════════════════════════════════════');
    }
  }

  void logInfo(String message, {Map<String, dynamic>? context}) {
    if (kDebugMode) {
      _printToConsole(message, level: LogLevel.info);
    }
  }

  void logWarning(String message, {Map<String, dynamic>? context}) {
    if (kDebugMode) {
      _printToConsole(message, level: LogLevel.warning);
    }
  }

  Future<void> logError(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    if (kDebugMode) {
      _printToConsole(message, level: LogLevel.error, error: error);
      if (stackTrace != null) {
        debugPrint(stackTrace.toString());
      }
    }

    if (error != null) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setContexts('error_info', {'message': message});
          if (context != null) {
            scope.setContexts('custom', context);
          }
        },
      );
    } else {
      await Sentry.captureMessage(
        message,
        level: SentryLevel.error,
        withScope: (scope) {
          if (context != null) {
            scope.setContexts('custom', context);
          }
        },
      );
    }
  }

  Future<void> logFatal(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    if (kDebugMode) {
      _printToConsole(message, level: LogLevel.fatal, error: error);
    }

    if (error != null) {
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('severity', 'fatal');
          scope.setContexts('error_info', {'message': message});
          if (context != null) {
            scope.setContexts('custom', context);
          }
        },
      );
    } else {
      await Sentry.captureMessage(
        message,
        level: SentryLevel.fatal,
        withScope: (scope) {
          scope.setTag('severity', 'fatal');
          if (context != null) {
            scope.setContexts('custom', context);
          }
        },
      );
    }
  }

  Future<void> logApiError({
    required String url,
    required int statusCode,
    String? method,
    dynamic responseBody,
    Map<String, dynamic>? requestBody,
  }) async {
    final message = 'API Error: $statusCode - $url';

    if (kDebugMode) {
      _printToConsole(message, level: LogLevel.error);
    }

    await Sentry.captureMessage(
      message,
      level: SentryLevel.error,
      withScope: (scope) {
        scope.setContexts('api_error', {
          'url': url,
          'method': method ?? 'UNKNOWN',
          'status_code': statusCode,
          'response_body': responseBody?.toString(),
          'request_body': requestBody?.toString(),
        });
        scope.setTag('error_type', 'api_error');
        scope.setTag('status_code', statusCode.toString());
      },
    );
  }

  Future<void> setUser({
    String? userId,
    String? email,
    String? username,
    Map<String, dynamic>? data,
  }) async {
    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: userId,
        email: email,
        username: username,
        data: data,
      ));
    });

    if (kDebugMode) {
      debugPrint('👤 User set: $userId - $email');
    }
  }

  Future<void> clearUser() async {
    await Sentry.configureScope((scope) {
      scope.setUser(null);
    });

    if (kDebugMode) {
      debugPrint('👤 User cleared');
    }
  }

  Future<void> setTag(String key, String value) async {
    await Sentry.configureScope((scope) {
      scope.setTag(key, value);
    });
  }

  Future<void> setContext(String key, Map<String, dynamic> value) async {
    await Sentry.configureScope((scope) {
      scope.setContexts(key, value);
    });
  }

  void captureFlutterError(FlutterErrorDetails details) {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
    Sentry.captureException(
      details.exception,
      stackTrace: details.stack,
    );
  }

  void _printToConsole(String message, {required LogLevel level, Object? error}) {
    final String emoji;
    switch (level) {
      case LogLevel.debug:
        emoji = '🔍';
        break;
      case LogLevel.info:
        emoji = 'ℹ️';
        break;
      case LogLevel.warning:
        emoji = '⚠️';
        break;
      case LogLevel.error:
        emoji = '❌';
        break;
      case LogLevel.fatal:
        emoji = '💀';
        break;
    }

    debugPrint('$emoji [${level.name.toUpperCase()}] $message');
    if (error != null) {
      debugPrint('   Error: $error');
    }
  }

  static bool get isEnabled => Sentry.isEnabled;
}
