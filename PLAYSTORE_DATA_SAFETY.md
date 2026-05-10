# Google Play Data Safety Draft

Dokumen ini membantu mengisi form **Data safety** di Google Play Console untuk aplikasi `catatin`.

## Ringkasan Praktik Data

Berdasarkan implementasi aplikasi saat ini:

- data akun dan catatan disimpan **secara lokal di perangkat**
- aplikasi **tidak mengirim catatan ke server developer**
- aplikasi **tidak memakai backend/cloud database** untuk fitur utama
- aplikasi **tidak menjual atau membagikan data** ke pihak ketiga untuk iklan

## Jenis Data yang Relevan

Data yang diproses aplikasi saat ini:

- Nama
- Alamat email
- Password lokal untuk login di perangkat
- Catatan buatan pengguna
- Preferensi tema
- Session login lokal

## Draft Jawaban untuk Play Console

Jawaban final tetap harus kamu cek ulang di Play Console, tapi untuk kondisi aplikasi sekarang biasanya akan mendekati ini:

### 1. Does your app collect or share any of the required user data types?

Panduan pengisian:
- Jika kamu menafsirkan **local on-device processing only** sebagai **tidak dikumpulkan / tidak dibagikan ke developer atau pihak ketiga**, maka jawaban cenderung `No`.
- Jika Play Console meminta kamu mendeklarasikan data yang tetap diproses aplikasi walau hanya lokal, isi sesuai jenis data di bawah dan pastikan konsisten dengan Privacy Policy.

### 2. Is all of the user data collected by your app encrypted in transit?

Draft jawaban:
- `Not applicable` untuk fitur inti saat ini, karena data utama tidak dikirim ke server developer dalam alur normal aplikasi.

### 3. Do you provide a way for users to request that their data is deleted?

Draft jawaban:
- `Yes`, secara praktis lewat:
  - hapus catatan di aplikasi
  - logout untuk mengakhiri sesi
  - hapus data aplikasi dari pengaturan device
  - uninstall aplikasi

## Jika Play Console Meminta Deklarasi per Kategori

Gunakan referensi ini:

### Personal info
- Name: digunakan untuk profil akun lokal
- Email address: digunakan untuk identitas login lokal

### App activity atau Files and docs
- Notes/content created by user: digunakan untuk fungsi inti pencatatan

### App info and performance
- Tidak ada analytics khusus developer yang dipakai oleh fitur inti saat ini

## Tujuan Penggunaan Data

Kalau Play Console menanyakan tujuan penggunaan, jawaban yang cocok untuk versi sekarang:

- App functionality
- Account management
- Personalization

## Yang Tidak Sesuai untuk Dicentang

Untuk kondisi aplikasi saat ini, jangan asal centang hal-hal berikut jika memang belum ada:

- data sharing for advertising
- analytics pihak ketiga
- cloud sync
- transfer data ke backend developer
- purchase history
- location
- contacts
- photos/videos dari device

## Catatan Penting

Sebelum submit:

1. samakan jawaban Data Safety dengan isi [PRIVACY_POLICY.md](C:\Users\jokop\Project_Flutter\helloworld\PRIVACY_POLICY.md)
2. kalau nanti kamu menambah backend, analytics, atau cloud sync, form ini harus diperbarui
3. jangan mengisi `No data collected` jika nanti aplikasi benar-benar mulai mengirim data ke server
