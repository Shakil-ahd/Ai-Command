import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/assistant/bloc/assistant_bloc.dart';
import '../../features/assistant/bloc/permission_bloc.dart';
import '../../features/assistant/data/repositories/app_repository_impl.dart';
import '../../features/assistant/data/repositories/contact_repository_impl.dart';
import '../../features/assistant/data/repositories/context_repository_impl.dart';
import '../../features/assistant/domain/repositories/app_repository.dart';
import '../../features/assistant/domain/repositories/contact_repository.dart';
import '../../features/assistant/domain/repositories/context_repository.dart';
import '../../features/assistant/domain/usecases/get_installed_apps_usecase.dart';
import '../../features/assistant/domain/usecases/launch_app_usecase.dart';
import '../../features/assistant/domain/usecases/make_call_usecase.dart';
import '../../features/assistant/domain/usecases/open_url_usecase.dart';
import '../../features/assistant/domain/usecases/process_command_usecase.dart';
import '../../features/assistant/services/fuzzy_matcher_service.dart';
import '../../features/assistant/services/intent_detection_service.dart';
import '../../features/assistant/services/speech_service.dart';
import '../../features/assistant/services/tts_service.dart';
import '../../features/assistant/platform/android_app_launcher.dart';

/// Global service locator (dependency injection via get_it).
final sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // ── External ─────────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  // ── Services ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<FuzzyMatcherService>(() => FuzzyMatcherService());
  sl.registerLazySingleton<IntentDetectionService>(
    () => IntentDetectionService(),
  );
  sl.registerLazySingleton<SpeechService>(() => SpeechService());
  sl.registerLazySingleton<TtsService>(() => TtsService());
  sl.registerLazySingleton<AndroidAppLauncher>(() => AndroidAppLauncher());

  // ── Repositories ─────────────────────────────────────────────────────────
  sl.registerLazySingleton<AppRepository>(
    () => AppRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ContactRepository>(
    () => ContactRepositoryImpl(),
  );
  sl.registerLazySingleton<ContextRepository>(
    () => ContextRepositoryImpl(sl()),
  );

  // ── Use Cases ─────────────────────────────────────────────────────────────
  sl.registerLazySingleton<GetInstalledAppsUseCase>(
    () => GetInstalledAppsUseCase(sl()),
  );
  sl.registerLazySingleton<LaunchAppUseCase>(
    () => LaunchAppUseCase(sl(), sl()),
  );
  sl.registerLazySingleton<MakeCallUseCase>(
    () => MakeCallUseCase(sl(), sl()),
  );
  sl.registerLazySingleton<OpenUrlUseCase>(
    () => OpenUrlUseCase(),
  );
  sl.registerLazySingleton<ProcessCommandUseCase>(
    () => ProcessCommandUseCase(
      intentDetectionService: sl(),
      launchAppUseCase: sl(),
      makeCallUseCase: sl(),
      openUrlUseCase: sl(),
      contextRepository: sl(),
      appRepository: sl(),
      contactRepository: sl(),
    ),
  );

  // ── BLoC ──────────────────────────────────────────────────────────────────
  sl.registerFactory<PermissionBloc>(() => PermissionBloc());
  sl.registerFactory<AssistantBloc>(
    () => AssistantBloc(
      processCommandUseCase: sl(),
      getInstalledAppsUseCase: sl(),
      speechService: sl(),
      ttsService: sl(),
      contextRepository: sl(),
    ),
  );
}
