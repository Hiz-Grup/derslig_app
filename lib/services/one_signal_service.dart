import 'dart:io';

import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  static Future<void> init() async {
    try {
      String appId = "9a0b6b0b-e1b8-41de-b071-2feae869602c";
      
      // Android 15 uyumluluğu için platform kontrolü
      if (Platform.isAndroid || Platform.isIOS) {
        await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
        OneSignal.initialize(appId);
        await OneSignal.Notifications.requestPermission(false);
      }
    } catch (e) {
      print('OneSignal başlatma hatası: $e');
      // Hata durumunda uygulamanın çalışmaya devam etmesi için exception'ı yakalıyoruz
    }
  }
}
