CREATE DATABASE IF NOT EXISTS rumahsakit;
CREATE DATABASE rumahsakit;
USE rumahsakit;

CREATE TABLE Pasien (
    pasien_id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    tanggal_lahir DATE NOT NULL,
    jenis_kelamin ENUM('L', 'P') NOT NULL,
    alamat TEXT,
    telepon VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE Dokter (
    dokter_id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    spesialisasi VARCHAR(50),
    telepon VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE Perawat (
    perawat_id INT AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    shift ENUM('Pagi', 'Siang', 'Malam') NOT NULL,
    telepon VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE Obat (
    obat_id INT AUTO_INCREMENT PRIMARY KEY,
    nama_obat VARCHAR(100) NOT NULL,
    jenis VARCHAR(50),
    stok INT DEFAULT 0 CHECK (stok >= 0),
    harga DECIMAL(12,2) NOT NULL CHECK (harga >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE Rawat_Inap (
    rawat_inap_id INT AUTO_INCREMENT PRIMARY KEY,
    pasien_id INT NOT NULL,
    dokter_id INT,
    tanggal_masuk DATE NOT NULL,
    tanggal_keluar DATE,
    ruangan VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rawat_pasien FOREIGN KEY (pasien_id) REFERENCES Pasien(pasien_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_rawat_dokter FOREIGN KEY (dokter_id) REFERENCES Dokter(dokter_id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_rawat_pasien (pasien_id),
    INDEX idx_rawat_dokter (dokter_id)
) ENGINE=InnoDB;

CREATE TABLE Rekam_Medis (
    rekam_medis_id INT AUTO_INCREMENT PRIMARY KEY,
    pasien_id INT NOT NULL,
    dokter_id INT,
    tanggal_periksa DATE NOT NULL,
    diagnosa TEXT,
    tindakan TEXT,
    obat_id INT,
    jumlah_obat INT DEFAULT 1 CHECK (jumlah_obat > 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_rm_pasien FOREIGN KEY (pasien_id) REFERENCES Pasien(pasien_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_rm_dokter FOREIGN KEY (dokter_id) REFERENCES Dokter(dokter_id) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_rm_obat FOREIGN KEY (obat_id) REFERENCES Obat(obat_id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_rm_pasien (pasien_id),
    INDEX idx_rm_dokter (dokter_id),
    INDEX idx_rm_obat (obat_id)
) ENGINE=InnoDB;

CREATE TABLE Pasien_Perawat (
    pasien_id INT NOT NULL,
    perawat_id INT NOT NULL,
    tanggal_tugas DATE NOT NULL,
    PRIMARY KEY(pasien_id, perawat_id, tanggal_tugas),
    CONSTRAINT fk_pp_pasien FOREIGN KEY (pasien_id) REFERENCES Pasien(pasien_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_pp_perawat FOREIGN KEY (perawat_id) REFERENCES Perawat(perawat_id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_pp_pasien (pasien_id),
    INDEX idx_pp_perawat (perawat_id)
) ENGINE=InnoDB;

DELIMITER //
CREATE TRIGGER trg_update_stok_obat_after_insert
AFTER INSERT ON Rekam_Medis
FOR EACH ROW
BEGIN
    IF NEW.obat_id IS NOT NULL THEN
        UPDATE Obat SET stok = stok - NEW.jumlah_obat WHERE obat_id = NEW.obat_id AND stok >= NEW.jumlah_obat;
        IF ROW_COUNT() = 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stok obat tidak cukup!';
        END IF;
    END IF;
END;
//
DELIMITER ;

CREATE OR REPLACE VIEW vw_Rekam_Medis_Detail AS
SELECT
    rm.rekam_medis_id,
    p.nama AS pasien,
    d.nama AS dokter,
    rm.tanggal_periksa,
    rm.diagnosa,
    rm.tindakan,
    o.nama_obat,
    rm.jumlah_obat
FROM Rekam_Medis rm
LEFT JOIN Pasien p ON rm.pasien_id = p.pasien_id
LEFT JOIN Dokter d ON rm.dokter_id = d.dokter_id
LEFT JOIN Obat o ON rm.obat_id = o.obat_id;

DELIMITER //
CREATE PROCEDURE sp_insert_rekam_medis (
    IN p_pasien_id INT,
    IN p_dokter_id INT,
    IN p_tanggal_periksa DATE,
    IN p_diagnosa TEXT,
    IN p_tindakan TEXT,
    IN p_obat_id INT,
    IN p_jumlah_obat INT
)
BEGIN
    IF p_obat_id IS NOT NULL THEN
        DECLARE v_stok INT;
        SELECT stok INTO v_stok FROM Obat WHERE obat_id = p_obat_id;
        IF v_stok < p_jumlah_obat THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Stok obat tidak cukup!';
        END IF;
    END IF;
    INSERT INTO Rekam_Medis (pasien_id, dokter_id, tanggal_periksa, diagnosa, tindakan, obat_id, jumlah_obat)
    VALUES (p_pasien_id, p_dokter_id, p_tanggal_periksa, p_diagnosa, p_tindakan, p_obat_id, p_jumlah_obat);
    IF p_obat_id IS NOT NULL THEN
        UPDATE Obat SET stok = stok - p_jumlah_obat WHERE obat_id = p_obat_id;
    END IF;
END;
//
DELIMITER ;

INSERT INTO Pasien (nama, tanggal_lahir, jenis_kelamin, alamat, telepon) VALUES
('Andi Saputra', '1985-04-20', 'L', 'Jl. Melati No. 10', '081234567890'),
('Siti Aminah', '1990-07-12', 'P', 'Jl. Mawar No. 5', '081298765432'),
('Budi Santoso', '1978-11-01', 'L', 'Jl. Kenanga No. 3', '081345678901'),
('Dewi Lestari', '2000-02-25', 'P', 'Jl. Cempaka No. 9', '081256789034'),
('Rizky Pratama', '1995-05-15', 'L', 'Jl. Anggrek No. 12', '081267890123'),
('Fitri Handayani', '1988-08-30', 'P', 'Jl. Dahlia No. 8', '081278901234');

INSERT INTO Dokter (nama, spesialisasi, telepon) VALUES
('Dr. UDIN', 'Cardiology', '081212345678'),
('Dr. Lina Kusuma', 'Pediatrics', '081223456789'),
('Dr. EJA odo', 'Orthopedics', '081234567891'),
('Dr. Maya Sari', 'Neurology', '081245678912'),
('Dr. Bima Prasetya', 'General Surgery', '081256789123'),
('Dr. Sari Dewi', 'Dermatology', '081267891234');

INSERT INTO Perawat (nama, shift, telepon) VALUES
('Sari Putri', 'Pagi', '081298765431'),
('Rina Anggraini', 'Siang', '081298765432'),
('Joko Susilo', 'Malam', '081298765433'),
('Tina Sari', 'Pagi', '081298765434'),
('Dewi Kartika', 'Siang', '081298765435'),
('Budi Hartono', 'Malam', '081298765436');

INSERT INTO Obat (nama_obat, jenis, stok, harga) VALUES
('Paracetamol', 'Analgesic', 100, 2000),
('Amoxicillin', 'Antibiotic', 50, 5000),
('Metformin', 'Antidiabetic', 75, 3000),
('Omeprazole', 'Antacid', 60, 4500),
('Cetirizine', 'Antihistamine', 80, 2500),
('Loratadine', 'Antihistamine', 90, 2700);

INSERT INTO Rawat_Inap (pasien_id, dokter_id, tanggal_masuk, tanggal_keluar, ruangan) VALUES
(1, 1, '2025-05-01', '2025-05-05', '101A'),
(2, 2, '2025-05-02', '2025-05-06', '102B'),
(3, 3, '2025-05-03', '2025-05-07', '103C'),
(4, 4, '2025-05-04', NULL, '104D'),
(5, 5, '2025-05-05', '2025-05-09', '105E'),
(6, 6, '2025-05-06', NULL, '106F');

CALL sp_insert_rekam_medis(1, 1, '2025-05-01', 'Flu ringan', 'Istirahat dan konsumsi obat', 1, 2);
CALL sp_insert_rekam_medis(2, 2, '2025-05-02', 'Infeksi saluran pernapasan', 'Pemberian antibiotik', 2, 1);
CALL sp_insert_rekam_medis(3, 3, '2025-05-03', 'Cedera tulang kaki', 'Pemasangan gips', NULL, 0);
CALL sp_insert_rekam_medis(4, 4, '2025-05-04', 'Migrain berat', 'Pemberian obat penghilang nyeri', 4, 3);
CALL sp_insert_rekam_medis(5, 5, '2025-05-05', 'Operasi usus buntu', 'Operasi dan perawatan pasca operasi', NULL, 0);
CALL sp_insert_rekam_medis(6, 6, '2025-05-06', 'Alergi kulit', 'Pemberian antihistamin', 6, 1);

INSERT INTO Pasien_Perawat (pasien_id, perawat_id, tanggal_tugas) VALUES
(1, 1, '2025-05-01'),
(2, 2, '2025-05-02'),
(3, 3, '2025-05-03'),
(4, 4, '2025-05-04'),
(5, 5, '2025-05-05'),
(6, 6, '2025-05-06');

