# Google ML Kit
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.internal.mlkit_vision_face.** { *; }

# TensorFlow Lite
-keep class org.tensorflow.lite.** { *; }
-dontwarn org.tensorflow.lite.gpu.GpuDelegateFactory$Options

# Keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# ErrorProne annotations (commonly missing with ML Kit)
-dontwarn com.google.errorprone.annotations.**

# javax.annotation (commonly missing)
-dontwarn javax.annotation.**

# Checkerframework (commonly missing)
-dontwarn org.checkerframework.**
