import 'package:derslig/controller/login_register_page_controller.dart';
import 'package:derslig/helper/hive_helpers.dart';
import 'package:derslig/helper/locator.dart';
import 'package:derslig/models/login_response_model.dart';
import 'package:derslig/models/user_model.dart';
import 'package:derslig/providers/purchase_provider.dart';
import 'package:derslig/services/logger_service.dart';
import 'package:flutter/widgets.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

class UserSyncService {
  static final UserSyncService _instance = UserSyncService._internal();
  static UserSyncService get instance => _instance;
  UserSyncService._internal();

  final _logger = LoggerService.instance;
  final _loginController = locator<LoginRegisterPageController>();

  Future<UserModel?> syncUserData(BuildContext context) async {
    final loginModel = HiveHelpers.getLoginModel();
    if (loginModel == null) {
      _logger.debugLog('🔄 [UserSync] No login model found - skipping sync');
      return null;
    }

    try {
      _logger.debugLog('🔄 [UserSync] Starting user sync...');

      final userModel = await _fetchUserFromBackend(loginModel);
      if (userModel == null || userModel.id == null) {
        _logger.debugLog('🔄 [UserSync] Backend returned null user - session may be expired');
        return null;
      }

      HiveHelpers.saveUserModel(userModel);
      _logger.debugLog('🔄 [UserSync] User saved to Hive: ${userModel.email}');

      await _updateRevenueCat(context, userModel);

      await _updateOneSignal(userModel);

      await _updateSentry(userModel);

      _logger.debugLog('🔄 [UserSync] Sync completed for user: ${userModel.id}');
      return userModel;
    } catch (e, stackTrace) {
      _logger.logError(
        'UserSync failed',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<UserModel?> _fetchUserFromBackend(LoginResponseModel loginModel) async {
    try {
      final userModel = await _loginController.userApiControl(
        xsrfToken: loginModel.xsrfToken,
        dersligCookie: loginModel.dersligCookie,
      );
      return userModel;
    } catch (e) {
      _logger.debugLog('🔄 [UserSync] Backend fetch failed: $e');
      return null;
    }
  }

  Future<void> _updateRevenueCat(BuildContext context, UserModel userModel) async {
    try {
      await context.read<PurchaseProvider>().loginToRevenueCat(
            userId: userModel.id.toString(),
            email: userModel.email,
            displayName: '${userModel.name ?? ''} ${userModel.surname ?? ''}'.trim(),
            phone: userModel.phone,
            type: userModel.type,
            isPremium: userModel.isPremium,
            schoolLevelId: userModel.schoolLevelId,
            gradeId: userModel.gradeId,
            branchId: userModel.branchId,
            schoolId: userModel.schoolId,
          );
      _logger.debugLog('🔄 [UserSync] RevenueCat updated');
    } catch (e) {
      _logger.debugLog('🔄 [UserSync] RevenueCat update failed: $e');
    }
  }

  Future<void> _updateOneSignal(UserModel userModel) async {
    try {
      final isPro = userModel.isPremium == 1;
      final userClass = userModel.gradeId ?? 0;

      await OneSignal.login(userModel.id.toString());

      String phone = (userModel.phone ?? '')
          .replaceAll('+9', '')
          .replaceAll(' ', '')
          .replaceAll('(', '')
          .replaceAll(')', '')
          .replaceAll('-', '');
      if (phone.length == 10) {
        phone = '0$phone';
      }
      phone = '+9$phone';

      if (phone.length > 5) {
        OneSignal.User.addSms(phone);
      }

      if (userModel.email != null && userModel.email!.isNotEmpty) {
        OneSignal.User.addEmail(userModel.email!);
      }

      OneSignal.User.removeTags(['class', 'isPremium']);
      OneSignal.User.addTagWithKey('class', userClass);
      OneSignal.User.addTagWithKey('isPremium', isPro.toString());

      _logger.debugLog('🔄 [UserSync] OneSignal updated - isPremium: $isPro');
    } catch (e) {
      _logger.debugLog('🔄 [UserSync] OneSignal update failed: $e');
    }
  }

  Future<void> _updateSentry(UserModel userModel) async {
    try {
      await _logger.setUser(
        userId: userModel.id.toString(),
        email: userModel.email,
        username: userModel.name,
      );
      _logger.debugLog('🔄 [UserSync] Sentry updated');
    } catch (e) {
      _logger.debugLog('🔄 [UserSync] Sentry update failed: $e');
    }
  }

  Future<void> clearUserData(BuildContext context) async {
    try {
      await context.read<PurchaseProvider>().logoutFromRevenueCat();
      await _logger.clearUser();
      await OneSignal.logout();
      _logger.debugLog('🔄 [UserSync] User data cleared from all services');
    } catch (e) {
      _logger.debugLog('🔄 [UserSync] Clear user data failed: $e');
    }
  }
}
