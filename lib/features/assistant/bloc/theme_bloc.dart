import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_themes.dart';
import 'theme_event_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences prefs;
  static const _themeKey = 'selected_theme_id';

  ThemeBloc({required this.prefs})
      : super(ThemeState(currentTheme: AppThemes.defaultDark)) {
    on<ThemeLoadEvent>(_onLoad);
    on<ThemeChangedEvent>(_onChanged);
  }

  void _onLoad(ThemeLoadEvent event, Emitter<ThemeState> emit) {
    final savedId = prefs.getString(_themeKey) ?? 'default_dark';
    final theme = AppThemes.getThemeById(savedId);
    AppTheme.setCurrent(theme);
    emit(state.copyWith(currentTheme: theme));
  }

  Future<void> _onChanged(
      ThemeChangedEvent event, Emitter<ThemeState> emit) async {
    final theme = AppThemes.getThemeById(event.themeId);
    AppTheme.setCurrent(theme);
    await prefs.setString(_themeKey, event.themeId);
    emit(state.copyWith(currentTheme: theme));
  }
}
