class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final String image;
  final bool isFavorite;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.image,
    this.isFavorite = false,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json["id"] ?? 0,
      name: json["name"] ?? '',
      status: json["status"] ?? '',
      species: json["species"] ?? '',
      gender: json["gender"] ?? '',
      image: json["image"] ?? '',
      isFavorite: json["isFavorite"] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'gender': gender,
      'image': image,
      'isFavorite': isFavorite,
    };
  }

  Character copyWith({
    int? id,
    String? name,
    String? status,
    String? species,
    String? gender,
    String? image,
    bool? isFavorite,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      species: species ?? this.species,
      gender: gender ?? this.gender,
      image: image ?? this.image,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
