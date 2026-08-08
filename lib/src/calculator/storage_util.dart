import 'package:get_secure_storage/get_secure_storage.dart';

class StorageUtil {
  static String container = "HasilHitung";
  static String password = "HasilHitung";

  static Future<void> init() async {
    await GetSecureStorage.init(
      container: StorageUtil.container,
      password: StorageUtil.password,
    );
  }

  static Future<void> saveData(String key, dynamic value) async {
    final box = GetSecureStorage(container: container, password: password);
    await box.write(key, value);
  }

  static Future<dynamic> readData(String key) async {
    final box = GetSecureStorage(container: container, password: password);
    dynamic obj = await box.read(key);
    if (obj is List<dynamic>) {
      return obj.map((e) => e.toString()).toList();
    }
    return obj;
  }

  static Future<void> deleteData(String key) async {
    final box = GetSecureStorage(container: container, password: password);
    await box.remove(key);
  }

  static Future<void> deleteAll() async {
    final box = GetSecureStorage(container: container, password: password);
    await box.erase();
  }
}
