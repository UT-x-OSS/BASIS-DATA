

# 🔥💀 MySQL Replication & Transaction Warfare — No GUI, Just CLI Grit

- 💻 Just copy & paste this to your machine — no config, no drama

> **Real ones don't use GUIs.**  
This is your full-throttle guide to setting up MySQL replication *exclusively* from the terminal — no phpMyAdmin, no mouse clicks, just raw shell power.  
Perfect for devs, sysadmins, and digital warriors who live in the terminal.

> ⚠️ Note: Tested and tuned on **Linux-to-Linux** setups. Cross-OS setups (like Linux to Windows) might behave differently — tread carefully.

---

## ❓ Apa Itu Master dan Slave?

Dalam konteks **MySQL Replication**, *Master* dan *Slave* adalah peran yang diberikan ke server:

- **Master**: Server utama yang menyimpan data asli dan mencatat semua perubahan data (insert, update, delete) ke dalam file log biner (binary log).
- **Slave**: Server cadangan yang membaca log biner dari master dan mereplikasi perubahan tersebut secara real-time.

### Kenapa Harus Pakai Master–Slave?

- 🛡️ **Backup real-time** — slave jadi backup otomatis.
- 📊 **Load balancing** — baca data dari slave untuk kurangi beban master.
- ⚙️ **Failover** — kalau master down, slave bisa dinaikkan jadi master baru.
- 🧪 **Testing** — slave bisa dipakai untuk testing data tanpa sentuh data asli.

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
echo "[mysqld]
server-id=1
log-bin=mysql-bin
binlog_format=MIXED" | sudo tee -a /etc/mysql/my.cnf
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
CREATE USER 'replica'@'%' IDENTIFIED BY 'password';
GRANT REPLICATION SLAVE ON *.* TO 'replica'@'%';
FLUSH PRIVILEGES;
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
echo "[mysqld]
server-id=2
relay-log=mysql-relay-bin
read_only=0" | sudo tee -a /etc/mysql/my.cnf
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
CHANGE MASTER TO MASTER_HOST='192.168.??.??', MASTER_USER='replica', MASTER_PASSWORD='password', MASTER_LOG_FILE='mysql-bin.00000?', MASTER_LOG_POS=123;
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


