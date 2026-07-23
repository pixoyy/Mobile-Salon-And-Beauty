import 'package:dio/dio.dart';
import 'package:salon_and_beauty/core/config/app_config.dart';
import 'package:salon_and_beauty/core/exceptions/api_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:salon_and_beauty/Views/Auth/LoginPage.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) async {
    try {
      return await _dio.get(path, queryParameters: params);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      return await _dio.patch(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException e) {
    if (e.response != null) {
      final message = e.response?.data?['message'] as String? ??
          'Terjadi kesalahan server';
      return ApiException(message, statusCode: e.response?.statusCode);
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return ApiException('Koneksi timeout. Periksa koneksi internet Anda.');
    }
    return ApiException('Tidak dapat terhubung ke server.');
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _redirectToLogin();
    }
    handler.next(err);
  }

  void _redirectToLogin() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('auth_token');
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _getGlobalContext();
      if (context != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    });
  }

  BuildContext? _getGlobalContext() {
    final navigator = _navigatorKey.currentContext;
    return navigator;
  }
}

final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
