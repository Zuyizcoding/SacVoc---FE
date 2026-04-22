/// Dio HTTP Client với Device ID header (Tính năng #3).
///
/// Tuân thủ:
///   - mobile-flutter #3: Repository Pattern — Dio là infrastructure, không phải UI
///   - Tính năng #3: Anonymous Identity — SHA256 device ID trong mọi request
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';

/// Provider cho Dio instance — inject vào Repository qua Riverpod
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30), // Gemini có thể mất ~6s
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Interceptor: inject Device ID vào mọi request (Tính năng #3)
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final deviceId = await _getOrCreateDeviceId();
        options.headers['X-Device-Id'] = deviceId;
        handler.next(options);
      },
    ),
  );

  return dio;
});

/// Lấy hoặc tạo Device ID (SHA256) — lưu SharedPreferences.
///
/// Flow: device_info_plus → SHA256 → SharedPreferences → header mọi request.
/// Không cần tạo tài khoản — anonymous identity (Tính năng #3).
Future<String> _getOrCreateDeviceId() async {
  final prefs = await SharedPreferences.getInstance();
  final cached = prefs.getString('device_id');
  if (cached != null) return cached;

  // Tạo mới từ device info
  final deviceInfo = DeviceInfoPlugin();
  String rawId;

  try {
    final androidInfo = await deviceInfo.androidInfo;
    rawId = androidInfo.id; // Android ID
  } catch (_) {
    try {
      final iosInfo = await deviceInfo.iosInfo;
      rawId = iosInfo.identifierForVendor ?? 'unknown_ios';
    } catch (_) {
      rawId = 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // SHA256 hash — không gửi raw device ID
  final deviceId = sha256.convert(utf8.encode(rawId)).toString();
  await prefs.setString('device_id', deviceId);

  return deviceId;
}
