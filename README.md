

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
sudo nano /etc/my.cnf.d/mariadb-server.cnf   # Arch

# atau

sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf  # Ubuntu/Debian

```
setup mariadb atau mysql

```bash
sudo mkdir /var/lib/mysql-maria
sudo chown mysql:mysql /var/lib/mysql-maria
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql-maria

# atau mysql

sudo mkdir /var/lib/mysql
sudo chown mysql:mysql /var/lib/mysql
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


> 📝 Save the `File` and `Position` — they’re your golden keys for setting up the slave.

---

## 🖥️ SLAVE SETUP

### 🔧 Configure MySQL on Slave

```bash
echo "[mysqld]
server-id=2
relay-log=mysql-relay-bin" | sudo tee -a /etc/mysql/my.cnf
```

Restart MySQL:

```bash
sudo systemctl restart mysql
```

Login to MySQL:

```bash
mysql -u root -p
```


Inside MySQL prompt:

```sql
CHANGE MASTER TO
  MASTER_HOST='ip_master',
  MASTER_USER='replica',
  MASTER_PASSWORD='password',
  MASTER_LOG_FILE='mysql-bin.000001',
  MASTER_LOG_POS=123;

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

Yap, di kampus — terutama pas kuliah Basis Data — dosen biasanya nyuruh pakai GUI kayak phpMyAdmin atau DBeaver. Itu emang buat bikin kita cepet paham konsep dasar tanpa pusing mikirin terminal.

Bahkan, di UT sendiri, di mata kuliah Basis Data, kita disuruh pakai phpMyAdmin buat ngerjain tugas-tugasnya.

Tapi kalau kamu pengen level yang lebih advanced, atau pengen tantangan lebih dalam ngulik MySQL secara teknis, maka repositori ini bisa banget jadi acuan.

Tapi...
> **Dunia nyata nggak selalu semanis antarmuka grafis.**

Repositori ini dibuat **dengan pendekatan CLI sepenuhnya** karena alasan berikut:

1. 🔍 **Kontrol Lebih Mendalam**  
   CLI memaksa kita memahami apa yang sebenarnya terjadi — bukan cuma klik dan selesai. Kamu belajar *bagaimana MySQL bekerja*, bukan sekadar *apa hasilnya*.

2. 🛠️ **Portabilitas & Automasi**  
   Di dunia profesional, server jarang punya GUI. Semua dilakukan via SSH dan terminal. Maka, kemampuan mengatur MySQL lewat CLI adalah skill esensial.

3. 🚀 **Lebih Cepat dan Ringan**  
   CLI tidak butuh RAM besar, tidak lambat, dan bisa dijalankan di server mana pun, bahkan VPS termurah sekalipun.

4. 🎯 **Latihan Mentalitas Engineer**  
   Bukan cuma ngerti *cara pakai alat*, tapi paham *bagaimana sistem bekerja di dalamnya*. Ini fondasi penting buat jadi software engineer, devops, atau sysadmin masa depan.



---

🛠️ Crafted by **Kiran** & **Shakira**, students of **Universitas Terbuka**.  
> 💡 Built with focus, driven by curiosity.  
> ⚡ Lightweight, reliable, and made to help you work smarter.  
> © 2025. All rights reserved.


