import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'features/assistant/bloc/assistant_bloc.dart';
import 'features/assistant/bloc/assistant_event_state.dart';
import 'features/assistant/bloc/permission_bloc.dart';
import 'features/assistant/bloc/permission_event_state.dart';
import 'features/assistant/ui/screens/assistant_screen.dart';
import 'features/assistant/ui/screens/onboarding_screen.dart';
import 'features/assistant/domain/repositories/context_repository.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await setupServiceLocator();

  final isFirstTime = !sl<ContextRepository>().isOnboardingCompleted();

  runApp(SakoAIApp(isFirstTime: isFirstTime));
}

class SakoAIApp extends StatelessWidget {
  final bool isFirstTime;
  const SakoAIApp({super.key, required this.isFirstTime});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PermissionBloc>(
          create: (_) => sl<PermissionBloc>()..add(CheckPermissionsEvent()),
        ),
        BlocProvider<AssistantBloc>(
          create: (_) => sl<AssistantBloc>()..add(AssistantInitializedEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'SakoAI',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: isFirstTime ? const OnboardingScreen() : const AssistantScreen(),
      ),
    );
  }
}
