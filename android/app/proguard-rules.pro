# Flutter specific ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep SharedPreferences
-keep class androidx.datastore.* { *; }

# Prevent obfuscation of classes used by reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses

# Keep model classes
-keep class com.sevenk.fit.** { *; }

# Google Play Core library (optional dependency - ignore warnings)
-dontwarn com.google.android.play.core.**

# Optimization
-optimizationpasses 5
-dontusemixedcaseclassnames
-verbose
-optimizations !code/simplification/arithmetic,!field/*,!class/merging/*
