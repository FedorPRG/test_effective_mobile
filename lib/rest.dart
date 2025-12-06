import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:test_effective_mobile/models/api_response.dart';

class Rest {
  static final _dio = Dio(
    BaseOptions(
      baseUrl: 'https://rickandmortyapi.com/api/',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  static Future<ApiResponse> getCharacters(int page) async {
    try {
      final response = await _dio.get(
        'character',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        return ApiResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load characters');
      }
    } catch (e) {
      log('Ошибка в запросе: $e');
      rethrow;
    }
  }
}
