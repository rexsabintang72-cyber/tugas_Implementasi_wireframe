# Product Requirements Document

## Product Name
catatin

## Package Name
com.ti24a6.app25

## Version
1.1

## Owner
Jokop

## Document Purpose
Dokumen ini merangkum kebutuhan produk untuk aplikasi `catatin` berdasarkan implementasi terbaru. PRD ini dapat dipakai untuk kebutuhan pengembangan, presentasi UTS, dan acuan saat menyiapkan upload ke Play Store.

## Product Summary
`catatin` adalah aplikasi catatan berbasis Flutter yang membantu pengguna menyimpan ide, tugas, catatan kuliah, dan catatan project dalam satu tempat yang rapi, ringan, dan mudah digunakan. Aplikasi ini mendukung multi-akun lokal di satu device, sehingga setiap akun memiliki data catatan masing-masing tanpa tercampur.

## Background
Banyak pengguna membutuhkan aplikasi catatan sederhana yang:

- cepat dibuka
- mudah dipakai
- tidak bergantung pada backend
- tetap bisa dipakai tanpa internet
- tetap menyimpan akun, sesi login, dan catatan setelah aplikasi ditutup

Produk ini dibuat dengan pendekatan local-first. Semua data akun dan catatan disimpan secara lokal di device menggunakan local storage, tanpa database server dan tanpa backend online untuk fitur utama.

## Goals

- Menyediakan aplikasi catatan yang rapi, modern, dan mudah dipakai.
- Memungkinkan pengguna membuat lebih dari satu akun lokal pada satu device.
- Memastikan setiap akun memiliki catatan yang terpisah.
- Menyimpan status login, preferensi tema, dan data catatan secara lokal agar tetap tersedia setelah aplikasi ditutup.
- Menyediakan alur tambah, edit, hapus, cari, dan filter catatan yang sederhana.
- Menyediakan mode terang dan mode gelap agar pengalaman penggunaan lebih nyaman.

## Non-Goals

- Sinkronisasi antar device
- Login online
- Integrasi backend atau database server
- Kolaborasi real-time
- Upload file, gambar, atau lampiran
- Reset password lewat email

## Target Users

- Mahasiswa
- Pelajar
- Pengguna personal yang ingin mencatat ide harian
- Pengguna yang butuh aplikasi catatan ringan tanpa akun online

## User Problems

- Catatan sering tercecer di banyak tempat
- Aplikasi catatan sering terlalu kompleks untuk kebutuhan sederhana
- Pengguna ingin lebih dari satu akun di satu device
- Pengguna tidak ingin kehilangan data setelah aplikasi ditutup
- Pengguna ingin catatan akun A tidak bercampur dengan akun B
- Pengguna ingin aplikasi yang bisa tetap dipakai walau tanpa koneksi internet

## Product Value

`catatin` memberikan solusi catatan lokal yang ringan dan fokus. Nilai utamanya adalah:

- sederhana untuk dipakai sehari-hari
- mendukung multi-akun lokal
- data tiap akun tetap terpisah
- sesi login tetap tersimpan
- tidak membutuhkan server

## Success Criteria

- Pengguna bisa register akun baru dengan mudah.
- Pengguna bisa login dan logout tanpa error.
- Pengguna bisa berpindah akun dengan aman.
- Pengguna tetap login setelah aplikasi ditutup dan dibuka lagi jika belum logout.
- Jika belum login, aplikasi menampilkan keadaan kosong untuk catatan.
- Catatan tetap tersimpan setelah aplikasi ditutup lalu dibuka lagi.
- Catatan akun berbeda tidak saling tercampur.
- Pengguna bisa berpindah antara mode terang dan gelap.
- Semua fitur utama berjalan tanpa koneksi internet.

## Core Features

### 1. Local Multi-Account Authentication

- Pengguna dapat membuat lebih dari satu akun lokal.
- Pengguna dapat login menggunakan email dan password akun yang sudah terdaftar.
- Pengguna dapat logout dari akun aktif saja tanpa menghapus akun lain yang tersimpan.
- Pengguna dapat ganti akun dari panel profil.
- Saat pindah ke akun lain dari profil, pengguna harus memasukkan password akun tujuan.
- Jika aplikasi ditutup dalam keadaan login, akun tetap dianggap login saat aplikasi dibuka kembali.

### 2. Note Management

- Pengguna dapat menambah catatan baru.
- Pengguna dapat melihat daftar catatan.
- Pengguna dapat membuka detail catatan.
- Pengguna dapat mengedit catatan.
- Pengguna dapat menghapus catatan.

### 3. Per-Account Note Isolation

- Setiap akun memiliki daftar catatan masing-masing.
- Catatan akun A tidak tampil saat akun B login.
- Akun baru yang belum memiliki catatan akan menampilkan keadaan kosong.
- Saat pengguna berpindah akun, daftar catatan langsung berubah mengikuti akun yang aktif.

### 4. Search and Filter

- Pengguna dapat mencari catatan berdasarkan judul, isi, atau kategori.
- Pengguna dapat memfilter catatan berdasarkan kategori cepat:
  - Prioritas
  - Kuliah
  - Project
  - Ide Baru

### 5. Local Persistence

- Data akun disimpan lokal di device.
- Data catatan per akun disimpan lokal di device.
- Status akun terakhir yang login disimpan lokal.
- Preferensi tema disimpan lokal.
- Sistem tidak memerlukan backend maupun database server.

### 6. Theme Mode

- Pengguna dapat mengganti mode terang dan gelap dari dalam aplikasi.
- Aplikasi mengingat pilihan tema setelah aplikasi ditutup.

## User Stories

- Sebagai pengguna, saya ingin membuat akun baru agar saya bisa memiliki workspace pribadi.
- Sebagai pengguna, saya ingin bisa membuat akun kedua agar data saya bisa dipisahkan.
- Sebagai pengguna, saya ingin login ke akun tertentu agar saya melihat catatan milik akun itu.
- Sebagai pengguna, saya ingin tetap login saat aplikasi dibuka lagi agar tidak perlu masuk ulang.
- Sebagai pengguna, saya ingin menambah dan mengedit catatan agar informasi saya selalu up to date.
- Sebagai pengguna, saya ingin menghapus catatan yang tidak diperlukan agar workspace tetap rapi.
- Sebagai pengguna, saya ingin mencari catatan dengan cepat agar tidak perlu scroll manual terlalu lama.
- Sebagai pengguna, saya ingin mengganti mode terang atau gelap agar aplikasi nyaman dilihat.
- Sebagai pengguna, saya ingin saat pindah akun dari profil tetap diminta password agar perpindahan akun lebih aman.

## Functional Requirements

### Authentication

- Sistem harus menyediakan mode register dan login.
- Sistem harus menolak register jika email sudah terdaftar.
- Tombol submit harus nonaktif jika field wajib belum terisi.
- Sistem harus menyimpan akun lokal setelah register berhasil.
- Sistem harus memulihkan sesi login terakhir saat aplikasi dibuka kembali.
- Sistem harus menampilkan daftar akun tersimpan untuk mempermudah login ulang.
- Sistem harus meminta password akun tujuan saat pengguna mengganti akun dari profil.

### Notes

- Sistem harus memungkinkan pembuatan catatan baru dengan:
  - judul
  - isi
  - kategori
- Sistem harus menyimpan waktu update catatan.
- Sistem harus memungkinkan edit catatan yang sudah ada.
- Sistem harus memungkinkan hapus catatan dengan aman.

### Data Separation

- Sistem harus mengaitkan setiap catatan ke akun yang sedang aktif.
- Sistem harus memisahkan catatan antar akun.
- Sistem harus menampilkan daftar catatan kosong untuk akun yang belum memiliki catatan.
- Sistem harus mengubah isi daftar catatan secara langsung saat akun aktif berubah.

### Local Storage

- Sistem harus menyimpan data secara lokal di device.
- Sistem harus tetap bisa berjalan tanpa internet.
- Sistem tidak boleh membutuhkan database server.

### Theme

- Sistem harus menyediakan mode terang dan gelap.
- Sistem harus mengingat tema terakhir yang dipilih.

## Non-Functional Requirements

- Aplikasi harus terasa ringan saat dibuka.
- Tampilan harus rapi, modern, dan mudah dibaca.
- Interaksi scroll harus tidak memiliki efek ketarik.
- UI harus tetap nyaman di ukuran mobile.
- Waktu respons untuk aksi tambah, edit, hapus, login, filter, dan ganti tema harus terasa instan.
- Saat startup, aplikasi harus memeriksa sesi tersimpan lebih dulu agar status login terasa realistis.

## Main User Flow

### Flow 1: Register Akun Baru

1. Pengguna menekan avatar profil.
2. Jika belum ada akun atau memilih mode register, halaman auth membuka form register.
3. Pengguna mengisi nama, email, dan password.
4. Pengguna menekan tombol daftar.
5. Akun disimpan lokal.
6. Pengguna langsung masuk ke aplikasi menggunakan akun tersebut.

### Flow 2: Login Akun

1. Pengguna menekan avatar profil.
2. Pengguna memilih mode login.
3. Pengguna mengisi email dan password.
4. Sistem memverifikasi data lokal.
5. Pengguna masuk ke akun terkait.

### Flow 3: Ganti Akun dari Profil

1. Pengguna menekan avatar saat sudah login.
2. Panel profil menampilkan akun tersimpan.
3. Pengguna menekan akun yang ingin dibuka.
4. Sistem menampilkan dialog password.
5. Jika password benar, akun aktif berubah.
6. Sistem menampilkan catatan milik akun yang dipilih.

### Flow 4: Tambah Catatan

1. Pengguna menekan tombol `Catatan Baru`.
2. Pengguna mengisi judul, isi, dan kategori.
3. Pengguna menekan `Simpan Catatan`.
4. Catatan muncul di daftar akun aktif.

### Flow 5: Edit atau Hapus Catatan

1. Pengguna membuka detail catatan.
2. Pengguna memilih edit atau hapus.
3. Sistem memperbarui data lokal akun aktif.

### Flow 6: Reopen App

1. Pengguna menutup aplikasi.
2. Pengguna membuka aplikasi kembali.
3. Sistem memeriksa sesi login lokal.
4. Jika sebelumnya masih login, akun tetap tersambung.
5. Jika belum login atau sudah logout, daftar catatan tampil kosong.

## Current Technical Scope

- Framework: Flutter
- Platform utama: Android mobile
- Penyimpanan lokal: `shared_preferences`
- Koneksi internet: tidak wajib
- Backend: tidak ada
- Database server: tidak ada
- Format release Android: `AAB`

## Risks

- Karena data hanya disimpan lokal, data tidak ikut pindah ke device lain.
- Jika aplikasi dihapus dari device, data lokal bisa hilang.
- `shared_preferences` cocok untuk skala ringan, tetapi bukan solusi ideal untuk data kompleks dalam jumlah besar.
- Password saat ini dipakai untuk kebutuhan login lokal dan belum memakai sistem keamanan server-side.

## Future Opportunities

- Export dan import data catatan
- Backup manual ke file lokal
- Pin catatan penting
- Hapus akun lokal dari device
- Enkripsi password lokal
- Sinkronisasi cloud di versi mendatang jika dibutuhkan
- Peningkatan keamanan autentikasi

## UTS Scope

Untuk kebutuhan UTS, aplikasi dianggap memenuhi scope inti jika:

- dapat dibuka dan digunakan tanpa backend
- dapat register dan login akun lokal
- dapat menyimpan lebih dari satu akun
- dapat menambah, edit, hapus, cari, dan filter catatan
- dapat mempertahankan sesi login saat aplikasi dibuka ulang
- dapat memisahkan data catatan antar akun
- dapat dibuild release untuk kebutuhan demonstrasi atau upload testing

## Acceptance Criteria

- Pengguna bisa membuat lebih dari satu akun.
- Pengguna bisa login ke akun mana pun yang sudah terdaftar.
- Pengguna tetap login setelah aplikasi ditutup dan dibuka kembali jika belum logout.
- Jika belum login, daftar catatan tampil kosong.
- Catatan tersimpan sesuai akun yang aktif.
- Catatan akun lain tidak ikut tampil.
- Akun baru tanpa catatan menampilkan daftar kosong.
- Tambah, edit, hapus, cari, dan filter catatan berjalan dengan baik.
- Mode terang dan gelap bisa diganti dan tetap tersimpan.
- Ganti akun dari profil meminta password akun tujuan.

## Notes

PRD ini disusun berdasarkan implementasi aplikasi saat ini, sehingga dapat dipakai sebagai dokumen acuan untuk pengembangan lanjutan, presentasi project, dan persiapan upload aplikasi untuk kebutuhan akademik maupun testing.
