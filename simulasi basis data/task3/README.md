


# 📊 Replikasi Basis Data

📚 Repositori ini dibuat untuk memudahkan kalian dalam mengerjakan tugas basis data, khususnya terkait setup dan konfigurasi replikasi MySQL.  
Di sini kami menyediakan panduan lengkap, mulai dari instalasi, konfigurasi master dan slave, hingga troubleshooting yang sering ditemui.


## Cara Menggunakan Repositori Ini

1. Ikuti panduan konfigurasi master dan slave secara berurutan.  
2. Gunakan perintah dan skrip yang sudah disediakan.  
3. Cek status replikasi secara berkala untuk memastikan sinkronisasi data.  
4. Jika menemui masalah, baca bagian troubleshooting di bawah.  
5. Jangan ragu untuk bertanya atau berdiskusi di komunitas kami di > https://discord.gg/zSkRxtuG  

---

> Terima kasih sudah menggunakan repositori ini! Semoga membantu dan mempermudah tugas basis data kalian.

> kalau lo pengen kontribusi, tambahin fitur, atau perbaiki isi repositori ini, langsung aja pull request. Kita welcome banget sama kontribusi dari lo!

---

## ❓ Master & Slave MySQL Replication

- Master: Server utama simpan data & catat perubahan di binary log.
- Slave: Server cadangan baca log master & sinkron real-time.

### Manfaat:

- 🛡️ Backup real-time otomatis.
- 📊 Beban baca dialihkan ke slave.
- ⚙️ Failover saat master down.
- 🧪 Testing tanpa ganggu data asli.

---


# install and setup mariadb or mysql

archlinux

```bash
# MySQL
sudo pacman -S mysql

# MariaDB
sudo pacman -S mariadb

```
debian or ubuntu

```bash
# MySQL
sudo apt update
sudo apt install mysql-server

# MariaDB
sudo apt install mariadb-server

```
setup bebrerapa OS

```bash
sudo nano /etc/my.cnf.d/server.cnf  # Arch

# atau

sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf  # Ubuntu/Debian

```
setup mariadb atau mysql

```bash
# Buat ulang folder data default (jika perlu)
sudo mkdir -p /var/lib/mysql

# Beri hak milik ke user mysql
sudo chown mysql:mysql /var/lib/mysql

# (Opsional tapi direkomendasikan) Set permission
sudo chmod 750 /var/lib/mysql

# Inisialisasi MariaDB dengan folder default
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

```

```bash
sudo systemctl enable mysql
sudo systemctl start mysql
```

### 🔧 MASTER SETUP 🖥️
```bash
sudo /etc/mysql/my.cnf
```

```bash
[mysqld]
server-id=1
log-bin=mysql-bin
binlog_format=MIXED
bind-address=0.0.0.0

# Opsional, kalau cuma mau replikasi database tertentu, contoh:
# binlog_do_db=nama_database
```

Restart MySQL:

```bash
sudo systemctl restart mysql
```

### 🔐 Create Replication User

```bash
mysql -u root -p
```

Inside MySQL prompt:

```sql
GRANT ALL PRIVILEGES, REPLICATION SLAVE ON *.* TO 'user'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;

```
```sql
SHOW MASTER STATUS;
```

```sql
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000001 |     123  |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
```


> 📝 Save the `File` and `Position` — they’re your golden keys for setting up the slave.

---

## 🖥️ SLAVE SETUP

### 🔧 Configure MySQL on Slave
```bash
sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf

# atau 

sudo nano /etc/mysql/my.cnf
```

```bash
[mysqld]
server-id=2
log_bin=mysql-bin
relay-log=mysql-relay-bin
relay-log-index=mysql-relay-bin.index
read_only=0  # Ubah ke 1 jika ingin replica bersifat read-only
skip-slave-start=1
log_slave_updates=1

```

Restart MySQL:

```bash
sudo systemctl restart mysql
```

Login to MySQL && Inside MySQL prompt :

```bash
mysql -u root -p
```

```sql
CHANGE MASTER TO MASTER_HOST='192.168.??.??', MASTER_USER='user', MASTER_PASSWORD='password', MASTER_LOG_FILE='mysql-bin.00000?', MASTER_LOG_POS=123;
```

```sql
START SLAVE;
```

LOOK FOR THIS IMPORTANT SECTION

```sql
SHOW SLAVE STATUS\G
```

```sql
+---------------------------------------------+
|          MYSQL REPLICATION STATUS           |
+---------------------------------------------+
| MASTER_HOST       | .........               |
| SLAVE_IO_RUNNING  | Yes                     |
| SLAVE_SQL_RUNNING | Yes                     |
| Last_Error        | NULL                    |
+---------------------------------------------+
```

> 💡 Having issues? Use:
```sql
STOP SLAVE;
RESET SLAVE;
```

---

## 🧪 TRANSACTION & TRIGGER SIMULATION

### 🔨 Create DB

```bash
mysql -u root -p
```

```bash
CREATE DATABASE db_transaksi;
```

Inside MySQL prompt:

```sql
DROP DATABASE IF EXISTS db_transaksi;
CREATE DATABASE db_transaksi;
USE db_transaksi;

CREATE TABLE user (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nama VARCHAR(100),
  saldo INT
);

CREATE TABLE log (
  id INT AUTO_INCREMENT PRIMARY KEY,
  aksi TEXT,
  waktu TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 🔥 Trigger Setup (Automatic Logging)

```sql
DELIMITER //

CREATE TRIGGER user_insert_log
AFTER INSERT ON user
FOR EACH ROW
BEGIN
  INSERT INTO log (aksi)
  VALUES (CONCAT('User ', NEW.nama, ' added with balance ', NEW.saldo));
END;
//

DELIMITER ;
```

### ✅ COMMIT Simulation

```sql
START TRANSACTION;
INSERT INTO user (nama, saldo) VALUES ('KIRAN', 10000);
INSERT INTO user (nama, saldo) VALUES ('SHAKIRA', 15000);
COMMIT;
```

### ❌ ROLLBACK Simulation

```sql
START TRANSACTION;
INSERT INTO user (nama, saldo) VALUES ('Gagal', 0);
ROLLBACK;
```

### 🔍 Check Results

```sql
SELECT * FROM user;
SELECT * FROM log;
```

---

## 🏁 Penting 

## ❓ Kenapa Repositori Ini Full CLI? Emangnya Nggak Lebih Gampang Pakai GUI?

Di dunia perkuliahan, terutama pada mata kuliah seperti Basis Data, mahasiswa biasanya diperkenalkan pada berbagai cara untuk belajar dan memahami konsep pengelolaan data. Salah satu pendekatan yang umum digunakan adalah dengan memakai antarmuka grafis atau GUI, seperti phpMyAdmin atau DBeaver. Alat-alat ini memang dirancang untuk memudahkan pemahaman dengan tampilan visual yang intuitif, sehingga kamu bisa langsung melihat hasil query atau manipulasi data secara real-time tanpa harus menghafal atau mengetik perintah yang rumit di terminal.

Di lingkungan Universitas Terbuka, penggunaan phpMyAdmin pun sudah menjadi standar dalam proses pembelajaran untuk mata kuliah Basis Data. Dengan GUI ini, mahasiswa dapat lebih cepat menangkap konsep dasar seperti pembuatan tabel, relasi antar data, hingga menjalankan query sederhana. Hal ini sangat membantu bagi mereka yang baru mulai belajar database karena fokus utama adalah memahami struktur data dan logika basis data tanpa terbebani oleh aspek teknis pengoperasian melalui command line.

Namun, di balik kemudahan dan kenyamanan GUI tersebut, ada kenyataan yang tidak bisa diabaikan: dalam praktik profesional, terutama di dunia IT dan pengembangan perangkat lunak, kamu tidak selalu punya akses ke antarmuka grafis. Server yang kamu kelola biasanya adalah mesin remote yang hanya bisa diakses lewat terminal, entah itu via SSH atau console langsung. Itulah mengapa kemampuan mengelola MySQL dan basis data lain melalui Command Line Interface (CLI) menjadi sangat krusial dan tidak boleh diabaikan.

Repositori ini dibuat dengan pendekatan yang sepenuhnya berbasis CLI untuk memberikan kamu pengalaman belajar yang lebih mendalam dan realistis. Dengan berfokus pada command line, kamu didorong untuk memahami bagaimana MySQL bekerja secara teknis dan struktural — bukan sekadar menekan tombol dan melihat hasilnya. Pendekatan ini memang menantang, tapi juga membuka kesempatan untuk menguasai skill yang jauh lebih bernilai dan esensial di dunia kerja.

Berikut beberapa alasan penting kenapa penggunaan CLI dalam pembelajaran MySQL sangat direkomendasikan:

1. 🔍 **Kontrol Lebih Mendalam**  
   CLI memberikan kamu kontrol penuh atas setiap aspek pengelolaan database. Kamu belajar untuk menulis query dengan tepat, memahami syntax, dan melihat apa yang sebenarnya terjadi ketika perintah dijalankan. Ini memupuk pemahaman yang jauh lebih kuat dibanding sekadar menggunakan GUI.

2. 🛠️ **Portabilitas dan Automasi**  
   Dalam banyak kasus profesional, server database tidak punya GUI. Semua pekerjaan dilakukan lewat terminal yang bisa diakses dari mana saja. Kemampuan memakai CLI memudahkan kamu untuk mengotomatisasi tugas rutin seperti backup, restore, monitoring, dan migrasi data.

3. 🚀 **Lebih Cepat dan Ringan**  
   CLI sangat efisien dan tidak memakan banyak sumber daya. Ini cocok untuk server dengan performa terbatas dan memungkinkan kamu untuk bekerja lebih cepat tanpa gangguan loading GUI yang berat.

4. 🎯 **Melatih Mentalitas Engineer**  
   Dengan belajar CLI, kamu tidak hanya paham alat, tapi juga mengembangkan pola pikir engineer yang problem solver, yang mampu melihat masalah sampai ke akar sistem dan mencari solusi efektif.

5. 📚 **Mengasah Kemandirian dan Skill Dokumentasi**  
   Menggunakan CLI membuat kamu terbiasa membaca dokumentasi, mencoba berbagai opsi perintah, dan memperdalam pengetahuan melalui eksperimen langsung.

6. 🔄 **Integrasi dengan Workflow Otomatisasi**  
   CLI memungkinkan penggabungan perintah dalam script untuk membangun workflow otomatis, yang sangat penting dalam pengembangan modern dan DevOps.




---

> 🛠️ Crafted by **Kiran** & **Shakira**, students of **Universitas Terbuka**.  
> 💡 Built with focus, driven by curiosity.  
> ⚡ Lightweight, reliable, and made to help you work smarter.  
> © 2025. All rights reserved.


