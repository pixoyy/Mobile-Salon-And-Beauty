# Glamora — Mobile Salon & Beauty

Glamora adalah aplikasi mobile berbasis Flutter untuk salon dan kecantikan yang dirancang untuk memudahkan pelanggan mencari stylist, melihat layanan, memesan janji, dan mengelola profil — semua dalam satu aplikasi yang elegan.

## Tujuan & Manfaat

- Mempermudah pelanggan menemukan stylist dan layanan yang sesuai.
- Menyederhanakan proses booking dan pembayaran (preview + checkout).
- Menyediakan dashboard personal dengan promo dan booking terdekat.
- Menyimpan sesi dan data pengguna secara lokal untuk pengalaman offline-first.

## Fitur Utama

- Dashboard personal dengan promo dan rekomendasi stylist
- Pencarian dan daftar stylist, halaman detail stylist
- Daftar layanan (service list) dan halaman detail layanan
- Alur booking lengkap: pilih layanan, pilih jadwal, preview, checkout
- Riwayat booking & booking terdekat
- Autentikasi (login/register) dan manajemen profil (edit profile, ganti password)
- Upload foto profil (base64 ataupun URL)
- Notifikasi visual di UI (ikon notifikasi), tombol aksi cepat

## Rincian Fitur

### Stylist (Daftar & Detail)

- Daftar stylist menampilkan foto (atau inisial), nama, spesialisasi, dan rating ringan.
- Halaman detail stylist menampilkan informasi lengkap: pengalaman dan layanan yang tersedia.
- Pengguna dapat memilih stylist sebagai preferensi saat membuat booking.
- Data stylist ditampilkan secara responsif dan mendukung pemfilteran sederhana (mis. berdasarkan nama).

### Service (Layanan)

- Setiap layanan memiliki nama, deskripsi singkat, durasi estimasi, dan harga dasar.
- Halaman detail layanan menampilkan informasi terperinci, termasuk kemungkinan add-on atau pilihan ekstra.
- Layanan dapat dipilih untuk dimasukkan ke dalam booking; UI menampilkan ringkasan durasi total dan perkiraan harga sebelum checkout.

### Booking (Alur Pemesanan)

- Alur booking terdiri dari beberapa langkah: pilih layanan → pilih stylist (opsional) → pilih tanggal & jam → review booking (preview) → checkout(penggunaan discount sesuai dengan total spend user).
- Preview booking menampilkan ringkasan layanan, stylist, lokasi, durasi dan total biaya.
- Riwayat booking dan booking terjadwal disimpan di local DB sehingga pengguna dapat meninjau riwayat dan status booking.

### Account Menu (Profil & Pengaturan)

- Menu akun menyediakan akses ke halaman `Edit Profile` untuk memperbarui nama, email, dan foto profil.
- Foto profil dapat diunggah dari perangkat menggunakan file picker; aplikasi menyimpan foto sebagai string `base64:` di DB dan menampilkannya menggunakan util `profileImageProvider`.
- Terdapat halaman `Change Password` untuk mengganti kata sandi (flow validasi dasar melalui UI local).
- Opsi logout membersihkan sesi lokal (`shared_preferences`) dan mengembalikan pengguna ke layar login.


## Teknologi & Paket Utama

- Flutter & Dart
- State management: `flutter_bloc`
- Local DB: `sqflite` (penyimpanan data seperti users, bookings, discounts)
- Persistensi kecil: `shared_preferences` (menyimpan sesi aktif)
- File picker untuk upload foto: `file_picker`

## Penyimpanan & Sesi

- Aplikasi menggunakan `shared_preferences` untuk menyimpan ID sesi aktif dan mem-bootstrap sesi pada startup (`lib/core/session/auth_session.dart`).
- Data domain (users, bookings, services, discounts) disimpan menggunakan SQLite via `sqflite` (lihat `lib/core/data/database_helper.dart`).
- Foto profil disimpan sebagai `base64:` string ketika di-upload dari perangkat, dan ditempatkan ke `imageUrl` pada model user.

## Struktur Proyek (ringkas)

- `lib/app.dart` — titik awal aplikasi & bootstrap
- `lib/features/dashboard/` — halaman Dashboard (promo, stylist, booking terdekat)
- `lib/features/auth/` — login, register, repository autentikasi
- `lib/features/user/` — profile, edit profile, user state
- `lib/features/booking/` — flow booking, checkout, history
- `lib/features/stylist/` — list & detail stylist
- `lib/features/service/` — daftar & detail layanan
- `lib/core/` — theme, session, utils, database helper

## Menjalankan Aplikasi (Development)

Persyaratan: Flutter SDK terinstal, Android Studio / Xcode untuk emulator/device.

1. Install dependency:

```bash
flutter pub get
```

2. Jalankan aplikasi (debug) ke perangkat/emulator:

```bash
flutter run
```

3. Jika ingin membersihkan data lokal saat development (reinstall): cabut app dari perangkat lalu `flutter run` kembali.

## Catatan Implementasi

- Session bootstrap: `AuthSession.bootstrap()` dipanggil saat startup (`lib/app.dart`) untuk memuat user dari `shared_preferences` + DB.
- Avatar: util `profileImageProvider` mendukung `base64:` (memory image) dan URL.
- Dashboard pada `AppShell` disajikan dalam `IndexedStack`; beberapa halaman menahan state — ada mekanisme versi key untuk memaksa rebuild pada tab tertentu.

## Kontribusi & Pengembangan

- Ikuti gaya fitur-first: setiap fitur diberi folder sendiri (`presentation`, `bloc`, `data`, `domain`).
- Untuk menambahkan font custom (mis. `Great Vibes`): letakkan file font di folder `fonts/` dan daftarkan di `pubspec.yaml`.

---

Jika Anda mau, saya bisa: menambahkan font `Great Vibes` sebagai asset dan mengaplikasikannya ke header, atau membuat README versi Bahasa Inggris/marketing-ready. Pilih tugas berikutnya yang Anda mau saya kerjakan.
