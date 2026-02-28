# Default ProGuard rules for Flutter
# Flutter wrapper
# https://flutter.dev/docs/deployment/android#enabling-proguard

# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

# If you use custom plugins or specific packages, you may need to add rules here
