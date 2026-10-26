import 'package:flutter/material.dart';
import 'package:rick_and_morty/features/characters/domain/domain.dart';
import 'package:rick_and_morty/features/characters/presentation/formatters/character_presentation.dart';
import 'package:rick_and_morty/shared/shared.dart';

class CharacterStatusBadge extends StatelessWidget {
  const CharacterStatusBadge({super.key, required this.status});

  final CharacterStatus status;

  @override
  Widget build(BuildContext context) => AppBadge(
    label: status.label,
    color: status.color,
    leading: Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
    ),
  );
}
