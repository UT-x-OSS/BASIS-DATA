# SIMULASI BASIS DATA UNIVERSITAS TERBUKA

Hallo, ini adalah simulasi database rumah sakit yang kami buat sebagai gambaran praktis untuk tugas kuliah Basis Data. Tujuannya supaya kalian bisa belajar bagaimana mengelola data rumah sakit secara terstruktur dan efisien, mulai dari data pasien, dokter, perawat, obat, hingga rekam medis lengkap dengan fitur-fitur seperti trigger otomatis untuk pengurangan stok obat dan stored procedure untuk memudahkan input data rekam medis. Simulasi ini dibuat agar kalian bisa eksplorasi lebih jauh, memahami konsep database secara nyata, dan mengaplikasikannya dalam proyek atau studi kalian selanjutnya. Semoga bisa jadi referensi yang membantu memperdalam pemahaman kalian dalam dunia basis data.

---

## Struktur Database

- **Pasien**  
  Data lengkap pasien: nama, tanggal lahir, jenis kelamin, alamat, dan nomor telepon.  
  Data terstruktur supaya mudah diakses dan dikelola.

- **Dokter**  
  Informasi dokter lengkap dengan spesialisasi dan kontak.  
  Memastikan dokter yang tepat menangani pasien.

- **Perawat**  
  Data perawat beserta shift kerja, supaya jadwal terorganisir.

- **Obat**  
  Stok dan harga obat tercatat dengan jelas.  
  Meminimalisir risiko kehabisan obat.

- **Rawat Inap**  
  Catatan pasien yang menjalani rawat inap, termasuk dokter penanggung jawab dan nomor kamar.  
  Memudahkan pemantauan durasi dan kapasitas rumah sakit.

- **Rekam Medis**  
  Detail pemeriksaan, diagnosa, tindakan, dan obat yang diberikan.  
  Ada mekanisme otomatis untuk mengurangi stok obat saat resep dibuat.

- **Pasien_Perawat**  
  Catatan perawat yang merawat pasien di tanggal tertentu.  
  Dokumentasi yang jelas dan akurat.

---

## Fitur Utama

- **Trigger Otomatis**  
  Mengurangi stok obat secara otomatis saat rekam medis dibuat. Jika stok tidak cukup, proses gagal.

- **Stored Procedure**  
  Memudahkan penambahan rekam medis dengan update stok obat yang terintegrasi.

- **View Rekam Medis**  
  Menampilkan data rekam medis lengkap dengan informasi pasien, dokter, perawat, dan obat secara praktis.

---

## Data Contoh

Sudah disediakan data pasien, dokter, perawat, dan obat sebagai contoh untuk percobaan dan pengujian.

---

## Cara Menggunakan

1. Import skrip SQL database ini ke sistem manajemen database Anda.  
2. Gunakan stored procedure yang tersedia untuk memasukkan data rekam medis agar semua update berjalan otomatis.  
3. Gunakan view `vw_Rekam_Medis_Detail` untuk melihat data rekam medis dengan lengkap.  
4. Pantau stok obat dan rawat inap secara berkala untuk menjaga kelancaran operasional.

---

## Penutup
> teman-teman mahasiswa dari Universitas Terbuka, saya ucapkan terima kasih banyak atas bantuan, dukungan, dan kerja sama kalian selama pengerjaan repository ini. Tanpa kalian, database ini nggak akan selesai dengan baik. Semoga hasil kerja kita bersama ini bisa bermanfaat buat belajar dan pengembangan selanjutnya. 
---

### AUTHOR

🔥 UT STUDENT - Information System 🔥

