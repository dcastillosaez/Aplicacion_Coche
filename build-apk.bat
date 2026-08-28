@echo off
setlocal

set "Path=F:\dev\flutter\bin;F:\dev\android-sdk\platform-tools;%Path%"
set "JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17.0.20.8-hotspot"
set "ANDROID_HOME=F:\dev\android-sdk"
set "TMP=F:\dev\tmp"
set "TEMP=F:\dev\tmp"

cd /d "%~dp0"

echo Compilando APK release desde %cd% ...
flutter build apk --release

if errorlevel 1 (
    echo.
    echo La compilacion ha fallado.
) else (
    echo.
    echo APK generado en build\app\outputs\flutter-apk\app-release.apk
)

pause
