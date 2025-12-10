import 'package:test_effective_mobile/models/api_response.dart';

abstract class ApiClient {
  Future<ApiResponse> getCharacters(int page);
}
