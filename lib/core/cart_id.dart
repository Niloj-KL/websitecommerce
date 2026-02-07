import 'package:shared_preferences/shared_preferences.dart';

class CartIdStore {
  static const _key = 'cart_id';

  static Future<String> getOrCreate() async {
    final sp = await SharedPreferences.getInstance();
    final existing = sp.getString(_key);
    if (existing != null && existing.isNotEmpty) return existing;

    final id = DateTime.now().millisecondsSinceEpoch.toString(); // simple unique
    await sp.setString(_key, id);
    return id;
  }
}
