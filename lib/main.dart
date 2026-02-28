import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/service_locator.dart';
import 'features/assistant/bloc/assistant_bloc.dart';
import 'features/assistant/bloc/assistant_event_state.dart';
import 'features/assistant/bloc/permission_bloc.dart';
import 'features/assistant/bloc/permission_event_state.dart';
import 'features/assistant/ui/screens/assistant_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize service locator (dependency injection)
  await setupServiceLocator();

  runApp(const AIAssistantApp());
}

class AIAssistantApp extends StatelessWidget {
  const AIAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Permission BLoC - handles runtime permissions
        BlocProvider<PermissionBloc>(
          create: (_) => sl<PermissionBloc>()..add(CheckPermissionsEvent()),
        ),
        // Main Assistant BLoC - handles all assistant logic
        BlocProvider<AssistantBloc>(
          create: (_) => sl<AssistantBloc>()..add(AssistantInitializedEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'AI Assistant',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const AssistantScreen(),
      ),
    );
  }
}
