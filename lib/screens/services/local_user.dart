// lib/services/local_user.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalUser {
  final String uid;
  final String name;
  final String role;

  LocalUser({required this.uid, required this.name, required this.role});

  Map<String, dynamic> toJson() => {'uid': uid, 'name': name, 'role': role};
  static LocalUser fromJson(Map<String, dynamic> j) =>
      LocalUser(uid: j['uid'] ?? '', name: j['name'] ?? '', role: j['role'] ?? '');
}

class LocalUserStore {
  static const String _key = 'local_user_v1';

  static Future<void> save(LocalUser user) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, jsonEncode(user.toJson()));
  }

  static Future<LocalUser?> load() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString(_key);
    if (s == null) return null;
    try {
      final m = Map<String, dynamic>.from(jsonDecode(s));
      return LocalUser.fromJson(m);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
  }
}
