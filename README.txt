REZVAN CHAT - SETUP
===================
1) SUPABASE (can be done on a phone)
   - supabase.com > New project (name: rezvan-chat)
   - SQL Editor > paste all of supabase.sql > Run
   - Authentication > Providers > Email: keep ON ("Confirm email" ON = link sent to email)
   - Project Settings > API: copy Project URL and anon key into lib/config.dart

2) CREATE ANDROID FILES (computer with Flutter installed)
   Open a terminal in this folder and run:
     flutter create --org com.rezvan --project-name rezvan_chat .
   (this keeps lib/ and pubspec.yaml and adds the android folder)

3) EDIT android/app/src/main/AndroidManifest.xml
   - Inside <manifest> (above <application>) add:
       <uses-permission android:name="android.permission.INTERNET"/>
       <uses-permission android:name="android.permission.RECORD_AUDIO"/>
   - Change android:label="rezvan_chat"  to  android:label="Rezvan Chat"

4) EDIT android/app/build.gradle (or build.gradle.kts)
   - set minSdk to 23   (minSdk = 23 / minSdkVersion 23)

5) BUILD
     flutter pub get
     flutter build apk --release
   APK: build/app/outputs/flutter-apk/app-release.apk  -> send it to your friends.

Tip: in Supabase email settings, free built-in email is limited (a few emails per hour).
For 50 users, add a free SMTP (e.g. Brevo/Resend) in Authentication > SMTP Settings.
