import 'package:equatable/equatable.dart';
import '../../../core/theme/app_themes.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class ThemeLoadEvent extends ThemeEvent {}

class ThemeChangedEvent extends ThemeEvent {
  final String themeId;
  const ThemeChangedEvent(this.themeId);
  @override
  List<Object?> get props => [themeId];
}

class ThemeState extends Equatable {
  final AppThemeData currentTheme;

  const ThemeState({required this.currentTheme});

  ThemeState copyWith({AppThemeData? currentTheme}) {
    return ThemeState(currentTheme: currentTheme ?? this.currentTheme);
  }

  @override
  List<Object?> get props => [currentTheme.id];
}
