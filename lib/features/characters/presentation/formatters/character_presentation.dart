import 'package:flutter/material.dart';
import 'package:rick_and_morty/features/characters/domain/domain.dart';
import 'package:rick_and_morty/shared/theme/app_colors.dart';

String displayCharacterValue(String value) =>
    value.isEmpty || value.toLowerCase() == 'unknown' ? 'Неизвестно' : value;

extension CharacterPresentation on Character {
  String get heroTag => 'character-$id';
  String get reference => '#${id.toString().padLeft(3, '0')}';
  String get speciesLabel => displayCharacterValue(species);
  String get originLabel => displayCharacterValue(origin);
  String get locationLabel => displayCharacterValue(location);
}

extension CharacterStatusPresentation on CharacterStatus {
  String get label => switch (this) {
    CharacterStatus.alive => 'Жив',
    CharacterStatus.dead => 'Мёртв',
    CharacterStatus.unknown => 'Неизвестно',
  };

  Color get color => switch (this) {
    CharacterStatus.alive => AppColors.accent,
    CharacterStatus.dead => AppColors.error,
    CharacterStatus.unknown => AppColors.muted,
  };
}
