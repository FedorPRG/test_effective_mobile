import 'package:test_effective_mobile/models/character.dart';
import 'package:test_effective_mobile/models/info.dart';

class ApiResponse {
  final Info info;
  final List<Character> results;

  ApiResponse({required this.info, required this.results});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      info: Info.fromJson(json["info"]),
      results: List<Character>.from(
        (json["results"] as List).map((item) => Character.fromJson(item)),
      ),
    );
  }
}
