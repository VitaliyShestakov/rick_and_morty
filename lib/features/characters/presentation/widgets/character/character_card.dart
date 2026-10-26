import 'package:flutter/material.dart';
import 'package:rick_and_morty/features/characters/domain/domain.dart';
import 'package:rick_and_morty/features/characters/presentation/formatters/character_presentation.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/character/character_portrait.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/character/character_status_badge.dart';
import 'package:rick_and_morty/shared/shared.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
  });

  final Character character;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => AppSurface(
    onTap: onTap,
    padding: const EdgeInsets.all(AppSpacing.sm),
    child: Row(
      children: [
        SizedBox(
          width: 100,
          height: 112,
          child: CharacterPortrait(character: character),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                character.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                character.speciesLabel,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: AppSpacing.sm),
              CharacterStatusBadge(status: character.status),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 13,
          color: AppColors.muted,
        ),
      ],
    ),
  );
}
