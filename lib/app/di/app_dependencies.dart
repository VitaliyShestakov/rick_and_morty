import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rick_and_morty/core/logging/app_logger.dart';
import 'package:rick_and_morty/core/logging/http_logging_interceptor.dart';
import 'package:rick_and_morty/core/network/api_client.dart';
import 'package:rick_and_morty/features/characters/data/data.dart';
import 'package:rick_and_morty/features/characters/domain/domain.dart';

class AppDependencies extends StatelessWidget {
  const AppDependencies({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<Dio>(
        create: (context) => ApiClient.create()
          ..interceptors.add(HttpLoggingInterceptor(context.read<AppLogger>())),
        dispose: (dio) => dio.close(force: true),
      ),
      RepositoryProvider<CharactersApi>(
        create: (context) => CharactersApi(context.read<Dio>()),
      ),
      RepositoryProvider<CharactersRepository>(
        create: (context) =>
            ApiCharactersRepository(context.read<CharactersApi>()),
      ),
    ],
    child: child,
  );
}
