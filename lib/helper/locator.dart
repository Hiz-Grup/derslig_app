import 'package:derslig/controller/login_register_page_controller.dart';
import 'package:derslig/controller/purchase_controller.dart';
import 'package:derslig/services/api_service.dart';
import 'package:derslig/services/navigation_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => PurchaseController());
  locator.registerLazySingleton(() => LoginRegisterPageController());
  locator.registerLazySingleton(() => ApiService());
}
