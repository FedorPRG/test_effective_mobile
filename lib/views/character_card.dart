import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:test_effective_mobile/models/character.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final Function clickFavorite;

  const CharacterCard({
    super.key,
    required this.character,
    required this.clickFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение персонажа
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: character.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, size: 40, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Информация о персонаже
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Имя
                  Text(
                    character.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Статус
                  Row(
                    children: [
                      // Индикатор статуса
                      Text(
                        'status - ${character.status}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _getStatusColor(character.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),

                  // Вид
                  Text(
                    'species - ${character.species}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),

                  // Пол
                  Text(
                    'Gender: ${character.gender}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),

                  // ID персонажа
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${character.id}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Кнопка "звездочка" для избранного
            IconButton(
              onPressed: () {
                clickFavorite();
              },
              icon: Icon(
                character.isFavorite ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'alive':
        return Colors.green;
      case 'dead':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
