import 'package:flutter/material.dart';
import 'package:rick_and_morty/features/characters/domain/domain.dart';
import 'package:rick_and_morty/features/characters/presentation/formatters/character_presentation.dart';
import 'package:rick_and_morty/shared/shared.dart';

class CharacterFacts extends StatelessWidget {
  const CharacterFacts({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const AppSectionHeader(title: 'ИНФОРМАЦИЯ'),
      const SizedBox(height: AppSpacing.md),
      AppSurface(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          children: [
            AppInfoRow(
              icon: Icons.biotech_outlined,
              label: 'Вид',
              value: character.speciesLabel,
            ),
            const Divider(height: 1),
            AppInfoRow(
              icon: Icons.public_rounded,
              label: 'Происхождение',
              value: character.originLabel,
            ),
            const Divider(height: 1),
            AppInfoRow(
              icon: Icons.location_on_outlined,
              label: 'Текущая локация',
              value: character.locationLabel,
            ),
          ],
        ),
      ),
    ],
  );
}
