import 'package:equatable/equatable.dart';

/// Represents an installed Android application.
class AppInfo extends Equatable {
  final String name; // Human-readable display name
  final String
      packageName; // Unique package identifier, e.g. com.facebook.katana
  final bool isSystemApp;

  const AppInfo({
    required this.name,
    required this.packageName,
    this.isSystemApp = false,
  });

  /// Normalized lowercase name for fuzzy matching.
  String get normalizedName => name.toLowerCase().trim();

  @override
  List<Object?> get props => [packageName];

  @override
  String toString() => 'AppInfo(name: $name, pkg: $packageName)';
}
