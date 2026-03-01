import 'package:equatable/equatable.dart';

class AppInfo extends Equatable {
  final String name;
  final String packageName;
  final bool isSystemApp;

  const AppInfo({
    required this.name,
    required this.packageName,
    this.isSystemApp = false,
  });
  String get normalizedName => name.toLowerCase().trim();

  @override
  List<Object?> get props => [packageName];

  @override
  String toString() => 'AppInfo(name: $name, pkg: $packageName)';
}
