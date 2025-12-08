import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:test_effective_mobile/models/character.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback clickFavorite;
  final bool withPulseAnimation;

  const CharacterCard({
    super.key,
    required this.character,
    required this.clickFavorite,
    this.withPulseAnimation = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение персонажа
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: character.image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 100,
                    height: 100,
                    color: theme.colorScheme.surface.withValues(alpha: 0.5),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 100,
                    height: 100,
                    color: theme.colorScheme.surface,
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: theme.disabledColor,
                    ),
                  ),
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
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
                        style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                          fontSize: 14,
                        ),
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
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),

                  // Пол
                  Text(
                    'Gender: ${character.gender}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),

                  // ID персонажа
                  const SizedBox(height: 4),
                  Text(
                    'ID: ${character.id}',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Кнопка "звездочка"
            if (withPulseAnimation)
              // Для AllCharacters - с анимацией переключения
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: IconButton(
                  key: ValueKey(character.isFavorite),
                  onPressed: clickFavorite,
                  icon: Icon(
                    character.isFavorite ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 38,
                  ),
                ),
              )
            else
              // Для Favorites - без анимации
              IconButton(
                onPressed: clickFavorite,
                icon: Icon(
                  character.isFavorite ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 38,
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
