# Keystore Release Guide

Dokumen ini menjelaskan konfigurasi signing release untuk aplikasi `catatin` dengan package `com.ti24a6.app25`.

## 1. File yang Sudah Disiapkan

File berikut sudah dibuat di project:

- Keystore release: `C:\Users\jokop\Project_Flutter\helloworld\android\upload-keystore.jks`
- Konfigurasi signing: `C:\Users\jokop\Project_Flutter\helloworld\android\key.properties`

Isi `key.properties` saat ini:

```properties
storePassword=CatatinUpload2026!
keyPassword=CatatinUpload2026!
keyAlias=upload
storeFile=upload-keystore.jks
```

## 2. Cara Kerja Signing di Project Ini

Project Android sudah dikonfigurasi untuk membaca `android/key.properties` saat build release.

Saat file tersebut tersedia:
- Gradle akan memakai `upload-keystore.jks` sebagai release signing key
- hasil build `AAB` akan siap dipakai untuk upload ke Google Play Console

Saat file tersebut tidak tersedia:
- project akan fallback ke debug signing
- hasil build tidak cocok untuk rilis production

## 3. Langkah Build AAB Release

Ikuti langkah ini dari folder project:

1. Masuk ke folder project Flutter:

```powershell
cd C:\Users\jokop\Project_Flutter\helloworld
```

2. Pastikan file berikut ada:

```powershell
Test-Path .\android\upload-keystore.jks
Test-Path .\android\key.properties
```

3. Jalankan build release:

```powershell
& 'C:\flutter\bin\flutter.bat' build appbundle --release --no-pub
```

4. Setelah berhasil, file output ada di:

```text
C:\Users\jokop\Project_Flutter\helloworld\build\app\outputs\bundle\release\app-release.aab
```

## 4. Cara Membuat Keystore Baru

Kalau suatu saat kamu ingin membuat keystore baru, jalankan perintah berikut:

```powershell
& 'C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe' `
  -genkeypair -v `
  -keystore 'C:\Users\jokop\Project_Flutter\helloworld\android\upload-keystore.jks' `
  -storepass 'PASSWORD_BARU' `
  -keypass 'PASSWORD_BARU' `
  -alias upload `
  -keyalg RSA `
  -keysize 2048 `
  -validity 10000 `
  -dname "CN=Jokop, OU=TI24A6, O=Catatin, L=Jakarta, ST=DKI Jakarta, C=ID"
```

Setelah itu, update `android/key.properties` agar nilainya sesuai dengan keystore baru.

## 5. Cadangan yang Wajib Disimpan

Simpan backup file ini di tempat yang aman:

- `C:\Users\jokop\Project_Flutter\helloworld\android\upload-keystore.jks`
- `C:\Users\jokop\Project_Flutter\helloworld\android\key.properties`

Kalau file keystore hilang, update versi aplikasi di Play Store bisa gagal karena signature tidak lagi cocok dengan versi sebelumnya.

## 6. Catatan Keamanan Penting

- Jangan upload `upload-keystore.jks` ke repository publik
- Jangan bagikan `key.properties` ke orang lain
- Ganti password default ini jika project akan benar-benar dipublikasikan
- Simpan salinan password di password manager atau catatan pribadi yang aman

## 7. Rekomendasi Sebelum Upload ke Play Store

Sebelum upload:

1. pastikan build `AAB` berhasil
2. simpan backup keystore
3. aktifkan Play App Signing di Google Play Console
4. upload file `AAB`, bukan `APK`
