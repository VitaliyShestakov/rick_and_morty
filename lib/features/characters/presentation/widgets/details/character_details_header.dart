import 'package:flutter/material.dart';
import 'package:rick_and_morty/features/characters/domain/domain.dart';
import 'package:rick_and_morty/features/characters/presentation/formatters/character_presentation.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/character/character_portrait.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/character/character_status_badge.dart';
import 'package:rick_and_morty/shared/shared.dart';

class CharacterDetailsHeader extends StatelessWidget {
  const CharacterDetailsHeader({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AspectRatio(
        aspectRatio: 1.12,
        child: CharacterPortrait(character: character, radius: AppRadii.hero),
      ),
      const SizedBox(height: AppSpacing.lg),
      CharacterStatusBadge(status: character.status),
      const SizedBox(height: AppSpacing.md),
      Text(character.name, style: Theme.of(context).textTheme.headlineLarge),
      const SizedBox(height: AppSpacing.xs),
      Text(
        character.speciesLabel,
        style: Theme.of(context).textTheme.titleMedium
            ?.copyWith(color: AppColors.muted),
      ),
    ],
  );
}
