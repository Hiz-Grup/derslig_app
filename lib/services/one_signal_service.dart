import 'dart:developer';

import 'package:onesignal_flutter/onesignal_flutter.dart';

class OneSignalService {
  static Future<void> init() async {
    String appId = "9a0b6b0b-e1b8-41de-b071-2feae869602c";
    await OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(appId);
    await OneSignal.Notifications.requestPermission(false);
  }
}
