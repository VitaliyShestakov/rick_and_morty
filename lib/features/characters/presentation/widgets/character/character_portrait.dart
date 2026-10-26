import 'package:flutter/material.dart';
import 'package:rick_and_morty/features/characters/domain/domain.dart';
import 'package:rick_and_morty/features/characters/presentation/formatters/character_presentation.dart';
import 'package:rick_and_morty/shared/shared.dart';

class CharacterPortrait extends StatelessWidget {
  const CharacterPortrait({
    super.key,
    required this.character,
    this.radius = AppRadii.control,
  });

  final Character character;
  final double radius;

  @override
  Widget build(BuildContext context) => Hero(
    tag: character.heroTag,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: AppNetworkImage(
        url: character.image,
        semanticLabel: 'Портрет: ${character.name}',
        errorIcon: Icons.person_outline_rounded,
      ),
    ),
  );
}
