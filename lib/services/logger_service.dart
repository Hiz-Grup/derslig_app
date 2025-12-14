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
      'https://c9f2d8f476d099530d6a1093886e84fc@o293205.ingest.us.sentry.io/4510511197650944';

  static Future<void> init({required Future<void> Function() appRunner}) async {
    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.debug = true;
        options.diagnosticLevel = SentryLevel.info;

        options.enableAutoSessionTracking = true;
        options.autoSessionTrackingInterval = const Duration(milliseconds: 30000);

        options.sampleRate = 1.0;
        options.tracesSampleRate = 1.0;

        options.attachViewHierarchy = true;

        options.environment = kDebugMode ? 'development' : 'production';

        options.sendDefaultPii = true;
        options.enableAutoNativeBreadcrumbs = true;
        options.enableAutoPerformanceTracing = true;

        options.attachScreenshot = false;

        options.beforeSend = (event, hint) {
          debugPrint('🚀 [Sentry] Event gönderiliyor: ${event.eventId}');
          debugPrint('   Type: ${event.type}');
          debugPrint('   Level: ${event.level}');
          debugPrint('   Message: ${event.message?.formatted}');
          if (event.exceptions != null && event.exceptions!.isNotEmpty) {
            debugPrint('   Exception: ${event.exceptions?.first.value}');
          }
          return event;
        };

        options.beforeBreadcrumb = (breadcrumb, hint) {
          if (kDebugMode) {
            debugPrint('🍞 [Sentry] Breadcrumb: ${breadcrumb?.message}');
          }
          return breadcrumb;
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

  Future<void> log(
    String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    if (kDebugMode) {
      _printToConsole(message, level: level, error: error);
    }

    await Sentry.captureMessage(
      message,
      level: _mapLogLevel(level),
      withScope: (scope) {
        if (context != null) {
          scope.setContexts('custom', context);
        }
      },
    );
  }

  Future<void> logInfo(String message, {Map<String, dynamic>? context}) async {
    await log(message, level: LogLevel.info, context: context);
  }

  Future<void> logWarning(String message, {Map<String, dynamic>? context}) async {
    await log(message, level: LogLevel.warning, context: context);
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
      await log(message, level: LogLevel.error, context: context);
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
      await log(message, level: LogLevel.fatal, context: context);
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

  void addBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
    SentryLevel? level,
  }) {
    if (kDebugMode) {
      debugPrint('🍞 Breadcrumb: $message');
    }

    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category ?? 'app',
        data: data,
        level: level ?? SentryLevel.info,
        timestamp: DateTime.now(),
      ),
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

  SentryLevel _mapLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return SentryLevel.debug;
      case LogLevel.info:
        return SentryLevel.info;
      case LogLevel.warning:
        return SentryLevel.warning;
      case LogLevel.error:
        return SentryLevel.error;
      case LogLevel.fatal:
        return SentryLevel.fatal;
    }
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

  Future<SentryId?> testSentryIntegration() async {
    // ignore: avoid_print
    print('🔄 [Sentry] Test başlatılıyor...');
    // ignore: avoid_print
    print('   DSN: ${sentryDsn.substring(0, 50)}...');
    // ignore: avoid_print
    print('   Environment: ${kDebugMode ? 'development' : 'production'}');
    // ignore: avoid_print
    print('   Sentry Enabled: ${Sentry.isEnabled}');

    if (!Sentry.isEnabled) {
      // ignore: avoid_print
      print('❌ [Sentry] SDK etkin değil! DSN kontrol edin.');
      return null;
    }

    try {
      final sentryId = await Sentry.captureException(
        Exception('Sentry Test - ${DateTime.now().toIso8601String()}'),
        stackTrace: StackTrace.current,
        withScope: (scope) {
          scope.setTag('test', 'true');
          scope.setTag('source', 'flutter_app');
          scope.setContexts('test_info', {
            'timestamp': DateTime.now().toIso8601String(),
            'environment': kDebugMode ? 'development' : 'production',
            'platform': 'flutter',
          });
        },
      );



      // ignore: avoid_print
      print('✅ [Sentry] Test başarılı!');
      // ignore: avoid_print
      print('   Event ID: $sentryId');
      // ignore: avoid_print
      print('   Dashboard\'da bu ID\'yi arayın: $sentryId');

      return sentryId;
    } catch (e, stack) {
      // ignore: avoid_print
      print('❌ [Sentry] Test başarısız: $e');
      // ignore: avoid_print
      print('   Stack: $stack');
      return null;
    }
  }

  static bool get isEnabled => Sentry.isEnabled;
}
