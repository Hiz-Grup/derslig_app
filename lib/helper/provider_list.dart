import 'package:derslig/providers/login_register_page_provider.dart';
import 'package:derslig/providers/page_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ChangeNotifierProvider<PageProvider>(create: (_) => PageProvider()),
  ChangeNotifierProvider<LoginRegisterPageProvider>(
      create: (_) => LoginRegisterPageProvider()),
];
