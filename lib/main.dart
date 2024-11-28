import 'package:flutter/material.dart';
import 'package:flutter_application_1/src/calculator/storage_util.dart';

import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageUtil.init();
  runApp(const MyApp());
}
