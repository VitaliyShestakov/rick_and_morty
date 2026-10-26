import 'package:flutter/material.dart';
import 'package:rick_and_morty/features/characters/domain/domain.dart';
import 'package:rick_and_morty/features/characters/presentation/formatters/character_presentation.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/details/character_details_header.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/details/character_facts.dart';
import 'package:rick_and_morty/shared/shared.dart';

class CharacterDetailsScreen extends StatelessWidget {
  const CharacterDetailsScreen({super.key, required this.character});

  final Character character;

  static Route<void> route(Character character) => MaterialPageRoute<void>(
    builder: (_) => CharacterDetailsScreen(character: character),
  );

  @override
  Widget build(BuildContext context) => AppScaffold(
    maxContentWidth: AppLayout.detailsWidth,
    appBar: AppBar(
      title: const Text('Досье персонажа', style: TextStyle(fontSize: 16)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppLayout.gutter),
          child: Center(
            child: Text(
              character.reference,
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
        ),
      ],
    ),
    body: SingleChildScrollView(
      key: const PageStorageKey('character-details'),
      padding: const EdgeInsets.fromLTRB(
        AppLayout.gutter,
        AppSpacing.sm,
        AppLayout.gutter,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CharacterDetailsHeader(character: character),
          const SizedBox(height: AppSpacing.lg),
          CharacterFacts(character: character),
        ],
      ),
    ),
  );
}
