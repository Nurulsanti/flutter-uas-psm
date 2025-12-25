# Flutter UAS PSM (Mobile App)

Proyek ini merupakan **aplikasi mobile berbasis Flutter** yang berfungsi sebagai **antarmuka (frontend)** untuk menampilkan dan mengelola data Business Intelligence. Aplikasi ini terhubung ke **API Backend Laravel** untuk pengelolaan produk, transaksi, serta visualisasi statistik penjualan melalui dashboard.

## Fitur Utama
  **Dashboard Monitoring**  
  Menyajikan visualisasi data penjualan dalam bentuk:
  - Pie Chart
  - Line Chart
  - Bar Chart  
  berdasarkan kategori, wilayah, segmen, serta tren waktu.

  **Manajemen Produk**  
  Menampilkan daftar produk beserta detail informasinya yang diambil dari API Backend.

  **Transaksi**  
  Form untuk mencatat transaksi baru secara cepat serta menampilkan riwayat transaksi.

  **Multi-Theme**  
  Mendukung pengaturan tema aplikasi menggunakan **Theme Provider**.

### Persyaratan Sistem

- Flutter SDK (disarankan versi terbaru)
- Dart SDK
- Koneksi internet untuk mengakses API Backend

#### Cara Instalasi
1. Clone Repository
```bash
git clone <url-repository-flutter>
cd flutter-uas-psm

2. Ambil Dependensi
flutter pub get

3. Konfigurasi API
lib/config/api_config.dart

4. Jalankan Aplikasi
flutter run

