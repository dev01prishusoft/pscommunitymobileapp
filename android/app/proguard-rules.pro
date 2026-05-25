# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in C:\Users\Work\AppData\Local\Android\sdk\tools\proguard\proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class com.google.crypto.tink.** { *; }

# For GetX
-keep class com.getx.** { *; }
-dontwarn com.getx.**

# For Dio
-keep class com.dio.** { *; }
-dontwarn com.dio.**

# Play Core Split Install
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
