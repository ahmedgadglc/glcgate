import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ApiService {
  final Dio _dio = Dio();
  final Connectivity _connectivity = Connectivity();

  static const Duration sendTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // Base URL - should be configured based on environment
  static const String baseUrl =
      'https://echo.glcpaints.com:7011/General/GeneralAPI';
  static const String spName = '[APIGeneralEchoOperation]';

  // User mobile number - can be set from login or left null for public access
  String? userMobileNo;

  Future<ApiResponse?> request(
    Map<String, dynamic> data, {
    String? url,
    String? spName,
  }) async {
    // Check connectivity - handle iOS simulator edge cases
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      // Check if list is empty or contains only ConnectivityResult.none
      if (connectivityResult.isEmpty ||
          (connectivityResult.length == 1 &&
              connectivityResult.first == ConnectivityResult.none)) {
        throw ApiException('لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال.');
      }
    } catch (e) {
      // If connectivity check fails, proceed with the request
      // The actual network call will fail if there's no internet
      if (e is ApiException) rethrow;
    }

    final Map<String, dynamic> headers = {
      'SP_Name': spName ?? ApiService.spName,
      'Content-Type': 'application/json',
    };

    // Build request data with required app version info
    final Map<String, dynamic> requestData = await _buildRequestData(data);

    try {
      final response = await _dio.request(
        url ?? baseUrl,
        options: Options(
          method: 'POST',
          headers: headers,
          sendTimeout: sendTimeout,
          receiveTimeout: receiveTimeout,
        ),
        data: requestData,
      );

      // Check response state before parsing
      final responseData = response.data as Map<String, dynamic>?;
      if (responseData != null) {
        final state = responseData['State'] ?? responseData['state'];
        if (state != null && state != 0) {
          final message =
              responseData['Message'] ?? responseData['message'] ?? '';
          throw ApiException(message.toString());
        }
      }

      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException(
        'خطأ في الاتصال بالخادم: ${e.message ?? "يرجى المحاولة لاحقًا"}',
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('خطأ غير متوقع: $e');
    }
  }

  Future<Map<String, dynamic>> _buildRequestData(
    Map<String, dynamic> data,
  ) async {
    // Get app version
    String appVersion = '1.0.0';
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = packageInfo.version;
    } catch (e) {
      // Use default version if package info fails
    }

    // Build app date versions
    final Map<String, dynamic> appDateVersions = {
      'AppVersionWeb': '1',
      'AppVersionAndroid': appVersion,
      'AppVersionIos': appVersion,
      'AppVersionDesktop': '1',
      'FireBaseToken': '', // Can be set later if needed
      'PlatForm': kIsWeb ? 'web' : Platform.operatingSystem,
    };

    // Build base data with User field
    final Map<String, dynamic> dataBase = {
      'User': userMobileNo ?? '', // Empty string if no user logged in
    };

    // Add app versions and operation data
    dataBase.addAll(appDateVersions);
    dataBase.addAll(data);

    return dataBase;
  }
}

class ApiResponse {
  final List<Version> versions;
  final Map<String, dynamic> data;
  final ResponseMetadata metadata;

  ApiResponse({
    required this.versions,
    required this.data,
    required this.metadata,
  });

  factory ApiResponse.fromJson(Map<String, dynamic>? jsonResponse) {
    if (jsonResponse == null) {
      return ApiResponse(
        versions: [],
        data: {},
        metadata: ResponseMetadata(state: -1, message: 'Invalid response'),
      );
    }

    List<Version> versions = [];
    if (jsonResponse['List0'] != null) {
      versions = (jsonResponse['List0'] as List)
          .map((e) => Version.fromJson(e))
          .toList();
    }

    final Map<String, dynamic> data = {};
    jsonResponse.forEach((key, value) {
      if (key.startsWith('List') && key != 'List0') {
        data[key] = value ?? [];
      }
    });

    final ResponseMetadata metadata = ResponseMetadata.fromJson(jsonResponse);

    return ApiResponse(versions: versions, data: data, metadata: metadata);
  }

  bool get hasError => metadata.state != 0;

  String? get errorMessage => hasError ? metadata.message : null;
}

class Version {
  final int id;
  final int tableId;
  final String tableDescription;
  final int versionNo;

  Version({
    required this.id,
    required this.tableId,
    required this.tableDescription,
    required this.versionNo,
  });

  factory Version.fromJson(Map<String, dynamic>? json) {
    return Version(
      id: json?['ID'] ?? 0,
      tableId: json?['TableID'] ?? 0,
      tableDescription: json?['TableDescription'] ?? '',
      versionNo: json?['VersionNo'] ?? 0,
    );
  }
}

class ResponseMetadata {
  final int? attachmentId;
  final int state;
  final String message;

  ResponseMetadata({
    this.attachmentId,
    required this.state,
    required this.message,
  });

  factory ResponseMetadata.fromJson(Map<String, dynamic>? json) {
    return ResponseMetadata(
      attachmentId: json?['AttachmentID'],
      state: json?['State'] ?? -1,
      message: json?['Message'] ?? '',
    );
  }
}

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}
