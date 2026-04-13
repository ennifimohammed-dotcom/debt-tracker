import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinService {
  static const _kEnabled = 'pin_enabled';
  static const _kHash    = 'pin_hash';
  static const _salt     = 'dtp_v1_salt';

  static String _hash(String pin) =>
      sha256.convert(utf8.encode('$_salt$pin')).toString();

  static Future<bool> isEnabled() async =>
      (await SharedPreferences.getInstance()).getBool(_kEnabled) ?? false;

  static Future<void> setPin(String pin) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kHash, _hash(pin));
    await p.setBool(_kEnabled, true);
  }

  static Future<void> disable() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kEnabled, false);
    await p.remove(_kHash);
  }

  static Future<bool> verify(String pin) async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kHash) == _hash(pin);
  }
}
