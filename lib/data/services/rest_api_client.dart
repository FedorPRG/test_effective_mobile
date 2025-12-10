import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:test_effective_mobile/data/contracts/api_client.dart';
import 'package:test_effective_mobile/models/api_response.dart';

class RestApiClient implements ApiClient {
  final Dio _dio;

  RestApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://rickandmortyapi.com/api/',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

  @override
  Future<ApiResponse> getCharacters(int page) async {
    try {
      final response = await _dio.get(
        'character',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        log('🌐 Страница $page загружена из сети');
        return ApiResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load characters');
      }
    } catch (e) {
      log('❌ Ошибка в запросе: $e');
      rethrow;
    }
  }
}
