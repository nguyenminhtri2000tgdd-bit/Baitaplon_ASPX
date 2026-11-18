/* ============================================================================
   BÀI TẬP LỚN ASPX - HỆ THỐNG THUÊ XE Ô TÔ
   CSDL : dt_rent  (SQL Server 2017 trở lên)

   Đây là bản CHUYỂN NGUYÊN VẸN từ CSDL PostgreSQL dt_rent cũ (file Thue_xe.sql):
   giữ nguyên tên bảng, tên cột, ràng buộc, chỉ mục và dữ liệu.

   Các điểm khác biệt bắt buộc khi chuyển PostgreSQL -> SQL Server:
   1) timestamptz  -> DATETIME2(0): lưu giờ địa phương (GMT+7), bỏ múi giờ.
   2) text         -> NVARCHAR(MAX); jsonb -> NVARCHAR(MAX) có CHECK ISJSON.
   3) boolean      -> BIT (1 = đúng, 0 = sai).
   4) Regex ~ '^[0-9]{12}$' -> LIKE / LEN.
   5) UNIQUE(so_cccd) cho phép nhiều NULL -> dùng filtered unique index.
   6) Ràng buộc loại trừ EXCLUDE USING gist (chống trùng lịch thuê xe)
      -> TRIGGER trg_phieu_thue_khong_trung_lich (báo lỗi số 50001).
   7) ?& kiểm tra khóa JSON -> JSON_VALUE(...) IS NOT NULL.

   Chạy toàn bộ file trong SSMS (F5). Có thể chạy lại nhiều lần: CSDL cũ bị xóa.
   ============================================================================ */

USE master;
GO
IF DB_ID(N'dt_rent') IS NOT NULL
BEGIN
    ALTER DATABASE dt_rent SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE dt_rent;
END
GO
CREATE DATABASE dt_rent COLLATE Vietnamese_CI_AS;
GO
USE dt_rent;
GO

/* ============================== 1. BẢNG ============================== */

CREATE TABLE hang_gplx (
    ma     VARCHAR(10)   NOT NULL CONSTRAINT hang_gplx_pkey PRIMARY KEY,
    mo_ta  NVARCHAR(150) NOT NULL
);
GO

CREATE TABLE hang_thanh_vien (
    id              SMALLINT IDENTITY(1,1) NOT NULL CONSTRAINT hang_thanh_vien_pkey PRIMARY KEY,
    ma              VARCHAR(20)  NOT NULL CONSTRAINT hang_thanh_vien_ma_key UNIQUE,
    ten             NVARCHAR(50) NOT NULL,
    phan_tram_giam  DECIMAL(5,2) NOT NULL CONSTRAINT df_hang_thanh_vien_giam DEFAULT 0,
    CONSTRAINT hang_thanh_vien_phan_tram_giam_check CHECK (phan_tram_giam >= 0 AND phan_tram_giam <= 100)
);
GO

CREATE TABLE nhan_vien (
    id              INT IDENTITY(1,1) NOT NULL CONSTRAINT nhan_vien_pkey PRIMARY KEY,
    ma_nhan_vien    VARCHAR(20)   NOT NULL CONSTRAINT nhan_vien_ma_nhan_vien_key UNIQUE,
    ho_ten          NVARCHAR(100) NOT NULL,
    so_dien_thoai   CHAR(10)      NOT NULL,
    dang_hoat_dong  BIT           NOT NULL CONSTRAINT df_nhan_vien_hoat_dong DEFAULT 1,
    ngay_tao        DATETIME2(0)  NOT NULL CONSTRAINT df_nhan_vien_ngay_tao DEFAULT SYSDATETIME(),
    CONSTRAINT nhan_vien_so_dien_thoai_check CHECK (so_dien_thoai LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);
GO

CREATE TABLE tai_khoan (
    id              INT IDENTITY(1,1) NOT NULL CONSTRAINT tai_khoan_pkey PRIMARY KEY,
    nhan_vien_id    INT           NOT NULL CONSTRAINT tai_khoan_nhan_vien_id_key UNIQUE,
    ten_dang_nhap   VARCHAR(50)   NOT NULL CONSTRAINT tai_khoan_ten_dang_nhap_key UNIQUE,
    mat_khau_hash   NVARCHAR(MAX) NOT NULL,
    vai_tro         VARCHAR(20)   NOT NULL,
    dang_hoat_dong  BIT           NOT NULL CONSTRAINT df_tai_khoan_hoat_dong DEFAULT 1,
    ngay_tao        DATETIME2(0)  NOT NULL CONSTRAINT df_tai_khoan_ngay_tao DEFAULT SYSDATETIME(),
    CONSTRAINT tai_khoan_vai_tro_check CHECK (vai_tro IN ('ADMIN', 'NHAN_VIEN'))
);
GO

CREATE TABLE khach_hang (
    id                  BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT khach_hang_pkey PRIMARY KEY,
    ma_khach            VARCHAR(20)   NOT NULL CONSTRAINT khach_hang_ma_khach_key UNIQUE,
    ho_ten              NVARCHAR(100) NOT NULL,
    so_dien_thoai       CHAR(10)      NOT NULL,
    so_cccd             VARCHAR(12)   NULL,
    dia_chi             NVARCHAR(255) NULL,
    hang_thanh_vien_id  SMALLINT      NOT NULL,
    ngay_tao            DATETIME2(0)  NOT NULL CONSTRAINT df_khach_hang_ngay_tao DEFAULT SYSDATETIME(),
    CONSTRAINT khach_hang_so_cccd_check CHECK (so_cccd IS NULL OR (LEN(so_cccd) = 12 AND so_cccd NOT LIKE '%[^0-9]%')),
    CONSTRAINT khach_hang_so_dien_thoai_check CHECK (so_dien_thoai LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
);
GO

CREATE TABLE gplx_khach_hang (
    khach_hang_id  BIGINT      NOT NULL,
    hang_gplx_ma   VARCHAR(10) NOT NULL,
    so_gplx        VARCHAR(20) NOT NULL,
    ngay_het_han   DATE        NULL,
    CONSTRAINT gplx_khach_hang_pkey PRIMARY KEY (khach_hang_id, hang_gplx_ma)
);
GO

CREATE TABLE nhom_xe (
    id                  SMALLINT IDENTITY(1,1) NOT NULL CONSTRAINT nhom_xe_pkey PRIMARY KEY,
    ma                  VARCHAR(30)   NOT NULL CONSTRAINT nhom_xe_ma_key UNIQUE,
    ten                 NVARCHAR(100) NOT NULL,
    loai_nhien_lieu     VARCHAR(10)   NOT NULL,
    so_cho              SMALLINT      NOT NULL,
    chinh_sach_gia      VARCHAR(40)   NOT NULL,
    gia_thue_ngay       DECIMAL(14,0) NOT NULL,
    km_toi_da_moi_ngay  INT           NULL,
    phi_vuot_km         DECIMAL(14,0) NULL,
    phi_tre_gio         DECIMAL(14,0) NOT NULL CONSTRAINT df_nhom_xe_phi_tre DEFAULT 0,
    tien_coc            DECIMAL(14,0) NOT NULL CONSTRAINT df_nhom_xe_tien_coc DEFAULT 0,
    CONSTRAINT ck_nhom_xe_gioi_han_km CHECK (
        (chinh_sach_gia = 'NGAY_CO_GIOI_HAN_KM' AND km_toi_da_moi_ngay IS NOT NULL AND phi_vuot_km IS NOT NULL)
        OR
        (chinh_sach_gia = 'NGAY_KHONG_GIOI_HAN_KM' AND km_toi_da_moi_ngay IS NULL AND phi_vuot_km IS NULL)),
    CONSTRAINT nhom_xe_chinh_sach_gia_check CHECK (chinh_sach_gia IN ('NGAY_CO_GIOI_HAN_KM', 'NGAY_KHONG_GIOI_HAN_KM')),
    CONSTRAINT nhom_xe_gia_thue_ngay_check CHECK (gia_thue_ngay > 0),
    CONSTRAINT nhom_xe_km_toi_da_moi_ngay_check CHECK (km_toi_da_moi_ngay > 0),
    CONSTRAINT nhom_xe_loai_nhien_lieu_check CHECK (loai_nhien_lieu IN ('DIEN', 'XANG', 'DAU')),
    CONSTRAINT nhom_xe_phi_tre_gio_check CHECK (phi_tre_gio >= 0),
    CONSTRAINT nhom_xe_phi_vuot_km_check CHECK (phi_vuot_km >= 0),
    CONSTRAINT nhom_xe_so_cho_check CHECK (so_cho > 0),
    CONSTRAINT nhom_xe_tien_coc_check CHECK (tien_coc >= 0)
);
GO

CREATE TABLE nhom_xe_gplx (
    nhom_xe_id    SMALLINT    NOT NULL,
    hang_gplx_ma  VARCHAR(10) NOT NULL,
    CONSTRAINT nhom_xe_gplx_pkey PRIMARY KEY (nhom_xe_id, hang_gplx_ma)
);
GO

CREATE TABLE xe (
    id              INT IDENTITY(1,1) NOT NULL CONSTRAINT xe_pkey PRIMARY KEY,
    ma_xe           VARCHAR(20)   NOT NULL CONSTRAINT xe_ma_xe_key UNIQUE,
    nhom_xe_id      SMALLINT      NOT NULL,
    hang_san_xuat   NVARCHAR(50)  NOT NULL,
    dong_xe         NVARCHAR(50)  NOT NULL,
    nam_san_xuat    SMALLINT      NOT NULL,
    bien_so         VARCHAR(15)   NOT NULL CONSTRAINT xe_bien_so_key UNIQUE,
    trang_thai      VARCHAR(20)   NOT NULL CONSTRAINT df_xe_trang_thai DEFAULT 'SAN_SANG',
    so_km_hien_tai  INT           NOT NULL CONSTRAINT df_xe_so_km DEFAULT 0,
    tinh_trang_pin  DECIMAL(5,2)  NULL,
    ghi_chu         NVARCHAR(MAX) NULL,
    ngay_tao        DATETIME2(0)  NOT NULL CONSTRAINT df_xe_ngay_tao DEFAULT SYSDATETIME(),
    CONSTRAINT xe_nam_san_xuat_check CHECK (nam_san_xuat >= 1990 AND nam_san_xuat <= 2100),
    CONSTRAINT xe_so_km_hien_tai_check CHECK (so_km_hien_tai >= 0),
    CONSTRAINT xe_tinh_trang_pin_check CHECK (tinh_trang_pin >= 0 AND tinh_trang_pin <= 100),
    CONSTRAINT xe_trang_thai_check CHECK (trang_thai IN ('SAN_SANG', 'DANG_CHO_THUE', 'DANG_BAO_TRI'))
);
GO

CREATE TABLE anh_xe (
    id            INT IDENTITY(1,1) NOT NULL CONSTRAINT anh_xe_pkey PRIMARY KEY,
    xe_id         INT           NOT NULL,
    duong_dan     NVARCHAR(500) NOT NULL,
    la_anh_chinh  BIT           NOT NULL CONSTRAINT df_anh_xe_chinh DEFAULT 0
);
GO

CREATE TABLE phieu_thue (
    id                   BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT phieu_thue_pkey PRIMARY KEY,
    ma_phieu             VARCHAR(20)   NOT NULL CONSTRAINT phieu_thue_ma_phieu_key UNIQUE,
    khach_hang_id        BIGINT        NOT NULL,
    xe_id                INT           NOT NULL,
    nhan_vien_id         INT           NOT NULL,
    thoi_diem_nhan       DATETIME2(0)  NOT NULL,
    thoi_diem_hen_tra    DATETIME2(0)  NOT NULL,
    so_ngay_thue         SMALLINT      NOT NULL,
    so_km_nhan           INT           NOT NULL,
    tinh_trang_pin_nhan  DECIMAL(5,2)  NULL,
    don_gia_ngay         DECIMAL(14,0) NOT NULL,
    km_toi_da_moi_ngay   INT           NULL,
    phi_vuot_km          DECIMAL(14,0) NULL,
    phi_tre_gio          DECIMAL(14,0) NOT NULL CONSTRAINT df_phieu_thue_phi_tre DEFAULT 0,
    tien_coc             DECIMAL(14,0) NOT NULL CONSTRAINT df_phieu_thue_tien_coc DEFAULT 0,
    phan_tram_giam       DECIMAL(5,2)  NOT NULL CONSTRAINT df_phieu_thue_giam DEFAULT 0,
    trang_thai           VARCHAR(15)   NOT NULL CONSTRAINT df_phieu_thue_trang_thai DEFAULT 'DANG_THUE',
    ghi_chu              NVARCHAR(MAX) NULL,
    ngay_tao             DATETIME2(0)  NOT NULL CONSTRAINT df_phieu_thue_ngay_tao DEFAULT SYSDATETIME(),
    CONSTRAINT ck_phieu_thue_thoi_gian CHECK (thoi_diem_hen_tra > thoi_diem_nhan),
    CONSTRAINT phieu_thue_don_gia_ngay_check CHECK (don_gia_ngay > 0),
    CONSTRAINT phieu_thue_phan_tram_giam_check CHECK (phan_tram_giam >= 0 AND phan_tram_giam <= 100),
    CONSTRAINT phieu_thue_so_km_nhan_check CHECK (so_km_nhan >= 0),
    CONSTRAINT phieu_thue_so_ngay_thue_check CHECK (so_ngay_thue >= 1),
    CONSTRAINT phieu_thue_tien_coc_check CHECK (tien_coc >= 0),
    CONSTRAINT phieu_thue_tinh_trang_pin_nhan_check CHECK (tinh_trang_pin_nhan >= 0 AND tinh_trang_pin_nhan <= 100),
    CONSTRAINT phieu_thue_trang_thai_check CHECK (trang_thai IN ('DANG_THUE', 'DA_TRA', 'DA_HUY'))
);
GO

CREATE TABLE tra_xe (
    id                     BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT tra_xe_pkey PRIMARY KEY,
    phieu_thue_id          BIGINT        NOT NULL CONSTRAINT tra_xe_phieu_thue_id_key UNIQUE,
    nhan_vien_id           INT           NOT NULL,
    thoi_diem_tra_thuc_te  DATETIME2(0)  NOT NULL,
    so_km_tra              INT           NOT NULL,
    km_da_di               INT           NOT NULL,
    so_gio_tre             INT           NOT NULL CONSTRAINT df_tra_xe_gio_tre DEFAULT 0,
    km_vuot                INT           NOT NULL CONSTRAINT df_tra_xe_km_vuot DEFAULT 0,
    tien_thue              DECIMAL(14,0) NOT NULL,
    phi_vuot_km            DECIMAL(14,0) NOT NULL CONSTRAINT df_tra_xe_phi_vuot DEFAULT 0,
    phi_tre                DECIMAL(14,0) NOT NULL CONSTRAINT df_tra_xe_phi_tre DEFAULT 0,
    tong_truoc_giam        DECIMAL(14,0) NOT NULL,
    tien_giam              DECIMAL(14,0) NOT NULL CONSTRAINT df_tra_xe_tien_giam DEFAULT 0,
    tong_phai_tra          DECIMAL(14,0) NOT NULL,
    xe_hu_hong             BIT           NOT NULL CONSTRAINT df_tra_xe_hu_hong DEFAULT 0,
    tinh_trang_pin_tra     DECIMAL(5,2)  NULL,
    ghi_chu                NVARCHAR(MAX) NULL,
    ngay_tao               DATETIME2(0)  NOT NULL CONSTRAINT df_tra_xe_ngay_tao DEFAULT SYSDATETIME(),
    CONSTRAINT ck_tra_xe_tong CHECK (tong_truoc_giam = tien_thue + phi_vuot_km + phi_tre
                                     AND tong_phai_tra = tong_truoc_giam - tien_giam),
    CONSTRAINT tra_xe_km_da_di_check CHECK (km_da_di >= 0),
    CONSTRAINT tra_xe_km_vuot_check CHECK (km_vuot >= 0),
    CONSTRAINT tra_xe_phi_tre_check CHECK (phi_tre >= 0),
    CONSTRAINT tra_xe_phi_vuot_km_check CHECK (phi_vuot_km >= 0),
    CONSTRAINT tra_xe_so_gio_tre_check CHECK (so_gio_tre >= 0),
    CONSTRAINT tra_xe_so_km_tra_check CHECK (so_km_tra >= 0),
    CONSTRAINT tra_xe_tien_giam_check CHECK (tien_giam >= 0),
    CONSTRAINT tra_xe_tien_thue_check CHECK (tien_thue >= 0),
    CONSTRAINT tra_xe_tinh_trang_pin_tra_check CHECK (tinh_trang_pin_tra >= 0 AND tinh_trang_pin_tra <= 100),
    CONSTRAINT tra_xe_tong_phai_tra_check CHECK (tong_phai_tra >= 0)
);
GO

CREATE TABLE thanh_toan (
    id              BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT thanh_toan_pkey PRIMARY KEY,
    phieu_thue_id   BIGINT        NOT NULL,
    nhan_vien_id    INT           NOT NULL,
    loai_giao_dich  VARCHAR(15)   NOT NULL,
    phuong_thuc     VARCHAR(15)   NOT NULL,
    so_tien         DECIMAL(14,0) NOT NULL,
    chi_tiet        NVARCHAR(MAX) NOT NULL CONSTRAINT df_thanh_toan_chi_tiet DEFAULT N'{}',   -- JSON
    thoi_diem       DATETIME2(0)  NOT NULL CONSTRAINT df_thanh_toan_thoi_diem DEFAULT SYSDATETIME(),
    CONSTRAINT ck_thanh_toan_chi_tiet CHECK (
        ISJSON(chi_tiet) = 1 AND (
            (phuong_thuc = 'TIEN_MAT'
                AND JSON_VALUE(chi_tiet, '$.tien_khach_dua') IS NOT NULL
                AND JSON_VALUE(chi_tiet, '$.tien_thoi') IS NOT NULL)
         OR (phuong_thuc = 'CHUYEN_KHOAN'
                AND JSON_VALUE(chi_tiet, '$.ngan_hang') IS NOT NULL
                AND JSON_VALUE(chi_tiet, '$.ma_giao_dich') IS NOT NULL)
         OR (phuong_thuc = 'VI_DIEN_TU'
                AND JSON_VALUE(chi_tiet, '$.ten_vi') IS NOT NULL
                AND JSON_VALUE(chi_tiet, '$.so_dien_thoai') IS NOT NULL))),
    CONSTRAINT thanh_toan_loai_giao_dich_check CHECK (loai_giao_dich IN ('DAT_COC', 'THANH_TOAN', 'HOAN_COC')),
    CONSTRAINT thanh_toan_phuong_thuc_check CHECK (phuong_thuc IN ('TIEN_MAT', 'CHUYEN_KHOAN', 'VI_DIEN_TU')),
    CONSTRAINT thanh_toan_so_tien_check CHECK (so_tien > 0)
);
GO

CREATE TABLE bao_tri (
    id             INT IDENTITY(1,1) NOT NULL CONSTRAINT bao_tri_pkey PRIMARY KEY,
    xe_id          INT           NOT NULL,
    nhan_vien_id   INT           NOT NULL,
    loai           VARCHAR(15)   NOT NULL,
    mo_ta          NVARCHAR(MAX) NOT NULL,
    ngay_bat_dau   DATE          NOT NULL,
    ngay_ket_thuc  DATE          NULL,
    chi_phi        DECIMAL(14,0) NOT NULL CONSTRAINT df_bao_tri_chi_phi DEFAULT 0,
    trang_thai     VARCHAR(15)   NOT NULL CONSTRAINT df_bao_tri_trang_thai DEFAULT 'DANG_THUC_HIEN',
    CONSTRAINT bao_tri_chi_phi_check CHECK (chi_phi >= 0),
    CONSTRAINT bao_tri_loai_check CHECK (loai IN ('DINH_KY', 'SUA_CHUA')),
    CONSTRAINT bao_tri_trang_thai_check CHECK (trang_thai IN ('DANG_THUC_HIEN', 'HOAN_THANH')),
    CONSTRAINT ck_bao_tri_ngay CHECK (ngay_ket_thuc IS NULL OR ngay_ket_thuc >= ngay_bat_dau)
);
GO

/* ============================ 2. KHÓA NGOẠI ============================ */

ALTER TABLE tai_khoan       ADD CONSTRAINT tai_khoan_nhan_vien_id_fkey        FOREIGN KEY (nhan_vien_id)       REFERENCES nhan_vien(id);
ALTER TABLE khach_hang      ADD CONSTRAINT khach_hang_hang_thanh_vien_id_fkey FOREIGN KEY (hang_thanh_vien_id) REFERENCES hang_thanh_vien(id);
ALTER TABLE gplx_khach_hang ADD CONSTRAINT gplx_khach_hang_khach_hang_id_fkey FOREIGN KEY (khach_hang_id)      REFERENCES khach_hang(id) ON DELETE CASCADE;
ALTER TABLE gplx_khach_hang ADD CONSTRAINT gplx_khach_hang_hang_gplx_ma_fkey  FOREIGN KEY (hang_gplx_ma)       REFERENCES hang_gplx(ma);
ALTER TABLE nhom_xe_gplx    ADD CONSTRAINT nhom_xe_gplx_nhom_xe_id_fkey       FOREIGN KEY (nhom_xe_id)         REFERENCES nhom_xe(id) ON DELETE CASCADE;
ALTER TABLE nhom_xe_gplx    ADD CONSTRAINT nhom_xe_gplx_hang_gplx_ma_fkey     FOREIGN KEY (hang_gplx_ma)       REFERENCES hang_gplx(ma);
ALTER TABLE xe              ADD CONSTRAINT xe_nhom_xe_id_fkey                 FOREIGN KEY (nhom_xe_id)         REFERENCES nhom_xe(id);
ALTER TABLE anh_xe          ADD CONSTRAINT anh_xe_xe_id_fkey                  FOREIGN KEY (xe_id)              REFERENCES xe(id) ON DELETE CASCADE;
ALTER TABLE phieu_thue      ADD CONSTRAINT phieu_thue_khach_hang_id_fkey      FOREIGN KEY (khach_hang_id)      REFERENCES khach_hang(id);
ALTER TABLE phieu_thue      ADD CONSTRAINT phieu_thue_xe_id_fkey              FOREIGN KEY (xe_id)              REFERENCES xe(id);
ALTER TABLE phieu_thue      ADD CONSTRAINT phieu_thue_nhan_vien_id_fkey       FOREIGN KEY (nhan_vien_id)       REFERENCES nhan_vien(id);
ALTER TABLE tra_xe          ADD CONSTRAINT tra_xe_phieu_thue_id_fkey          FOREIGN KEY (phieu_thue_id)      REFERENCES phieu_thue(id);
ALTER TABLE tra_xe          ADD CONSTRAINT tra_xe_nhan_vien_id_fkey           FOREIGN KEY (nhan_vien_id)       REFERENCES nhan_vien(id);
ALTER TABLE thanh_toan      ADD CONSTRAINT thanh_toan_phieu_thue_id_fkey      FOREIGN KEY (phieu_thue_id)      REFERENCES phieu_thue(id);
ALTER TABLE thanh_toan      ADD CONSTRAINT thanh_toan_nhan_vien_id_fkey       FOREIGN KEY (nhan_vien_id)       REFERENCES nhan_vien(id);
ALTER TABLE bao_tri         ADD CONSTRAINT bao_tri_xe_id_fkey                 FOREIGN KEY (xe_id)              REFERENCES xe(id);
ALTER TABLE bao_tri         ADD CONSTRAINT bao_tri_nhan_vien_id_fkey          FOREIGN KEY (nhan_vien_id)       REFERENCES nhan_vien(id);
GO

/* ============================== 3. CHỈ MỤC ============================== */

-- UNIQUE(so_cccd) của PostgreSQL cho phép nhiều NULL; SQL Server thì không -> dùng filtered index
CREATE UNIQUE INDEX khach_hang_so_cccd_key ON khach_hang(so_cccd) WHERE so_cccd IS NOT NULL;
-- Mỗi xe chỉ có tối đa 1 ảnh chính
CREATE UNIQUE INDEX uq_anh_xe_anh_chinh ON anh_xe(xe_id) WHERE la_anh_chinh = 1;

CREATE INDEX ix_bao_tri_xe            ON bao_tri(xe_id);
CREATE INDEX ix_khach_hang_sdt        ON khach_hang(so_dien_thoai);
CREATE INDEX ix_phieu_thue_khach      ON phieu_thue(khach_hang_id);
CREATE INDEX ix_phieu_thue_nhan       ON phieu_thue(thoi_diem_nhan);
CREATE INDEX ix_phieu_thue_trang_thai ON phieu_thue(trang_thai);
CREATE INDEX ix_phieu_thue_xe         ON phieu_thue(xe_id);
CREATE INDEX ix_thanh_toan_phieu      ON thanh_toan(phieu_thue_id);
CREATE INDEX ix_xe_nhom_xe            ON xe(nhom_xe_id);
CREATE INDEX ix_xe_trang_thai         ON xe(trang_thai);
GO

/* ================= 4. TRIGGER CHỐNG TRÙNG LỊCH THUÊ XE =================
   Thay cho ràng buộc loại trừ của PostgreSQL:
     EXCLUDE USING gist (xe_id WITH =, tstzrange(thoi_diem_nhan, thoi_diem_hen_tra) WITH &&)
     WHERE (trang_thai = 'DANG_THUE')
   Một xe không được có 2 phiếu 'DANG_THUE' mà khoảng thời gian [nhận, hẹn trả) chồng lên nhau.
   Khi vi phạm: hủy giao dịch và báo lỗi số 50001 (tương đương mã lỗi 23P01 bên PostgreSQL). */
CREATE TRIGGER trg_phieu_thue_khong_trung_lich
ON phieu_thue
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN phieu_thue p WITH (UPDLOCK, HOLDLOCK)
             ON p.xe_id = i.xe_id AND p.id <> i.id
        WHERE i.trang_thai = 'DANG_THUE'
          AND p.trang_thai = 'DANG_THUE'
          AND i.thoi_diem_nhan < p.thoi_diem_hen_tra
          AND p.thoi_diem_nhan < i.thoi_diem_hen_tra
    )
    BEGIN
        ROLLBACK TRANSACTION;
        THROW 50001, N'Xe đã có phiếu thuê trùng thời gian.', 1;
    END
END;
GO

/* ============================ 5. DỮ LIỆU CŨ ============================
   Chuyển nguyên từ bản sao lưu dt_rent (giờ đã đổi sang giờ địa phương). */

-- hang_gplx (3 dòng)
INSERT INTO hang_gplx (ma, mo_ta) VALUES
(N'A1', N'Mô tô (không được lái ô tô)'),
(N'B1', N'Ô tô số tự động'),
(N'B2', N'Ô tô số sàn và số tự động');

-- hang_thanh_vien (3 dòng)
SET IDENTITY_INSERT hang_thanh_vien ON;
INSERT INTO hang_thanh_vien (id, ma, ten, phan_tram_giam) VALUES
(1, N'VANG_LAI', N'Khách vãng lai', 0.00),
(2, N'BAC', N'Thành viên hạng Bạc', 5.00),
(3, N'VANG', N'Thành viên hạng Vàng', 10.00);
SET IDENTITY_INSERT hang_thanh_vien OFF;

-- nhan_vien (2 dòng)
SET IDENTITY_INSERT nhan_vien ON;
INSERT INTO nhan_vien (id, ma_nhan_vien, ho_ten, so_dien_thoai, dang_hoat_dong, ngay_tao) VALUES
(1, N'NV001', N'Nguyễn Văn Quản Lý', N'0901000001', 1, '2026-10-22 22:11:59'),
(2, N'NV002', N'Trần Thị Nhân Viên', N'0901000002', 1, '2026-10-22 22:11:59');
SET IDENTITY_INSERT nhan_vien OFF;

-- tai_khoan: (bảng rỗng trong CSDL cũ)
-- khach_hang (4 dòng)
SET IDENTITY_INSERT khach_hang ON;
INSERT INTO khach_hang (id, ma_khach, ho_ten, so_dien_thoai, so_cccd, dia_chi, hang_thanh_vien_id, ngay_tao) VALUES
(1, N'KH004', N'Nguyễn Thị Dung', N'0912345004', N'087200000004', NULL, 1, '2026-10-22 22:11:59'),
(2, N'KH001', N'Lê Văn An', N'0912345001', N'087200000001', NULL, 1, '2026-10-22 22:11:59'),
(3, N'KH002', N'Phạm Thị Bình', N'0912345002', N'087200000002', NULL, 2, '2026-10-22 22:11:59'),
(4, N'KH003', N'Võ Minh Cường', N'0912345003', N'087200000003', NULL, 3, '2026-10-22 22:11:59');
SET IDENTITY_INSERT khach_hang OFF;

-- gplx_khach_hang (5 dòng)
INSERT INTO gplx_khach_hang (khach_hang_id, hang_gplx_ma, so_gplx, ngay_het_han) VALUES
(1, N'A1', N'GPLX-0005', '2035-03-10'),
(2, N'B2', N'GPLX-0001', '2031-05-01'),
(3, N'B1', N'GPLX-0002', '2030-08-15'),
(4, N'B2', N'GPLX-0004', '2032-01-20'),
(4, N'B1', N'GPLX-0003', '2032-01-20');

-- nhom_xe (3 dòng)
SET IDENTITY_INSERT nhom_xe ON;
INSERT INTO nhom_xe (id, ma, ten, loai_nhien_lieu, so_cho, chinh_sach_gia, gia_thue_ngay, km_toi_da_moi_ngay, phi_vuot_km, phi_tre_gio, tien_coc) VALUES
(1, N'OTO_DIEN_5CHO', N'Ô tô điện 5 chỗ', N'DIEN', 5, N'NGAY_CO_GIOI_HAN_KM', 800000, 200, 2000, 80000, 5000000),
(2, N'OTO_XANG_5CHO', N'Ô tô xăng 5 chỗ', N'XANG', 5, N'NGAY_KHONG_GIOI_HAN_KM', 650000, NULL, NULL, 65000, 3000000),
(3, N'OTO_SUV_7CHO', N'Ô tô SUV 7 chỗ', N'XANG', 7, N'NGAY_CO_GIOI_HAN_KM', 1000000, 250, 2500, 100000, 6000000);
SET IDENTITY_INSERT nhom_xe OFF;

-- nhom_xe_gplx (4 dòng)
INSERT INTO nhom_xe_gplx (nhom_xe_id, hang_gplx_ma) VALUES
(1, N'B1'),
(1, N'B2'),
(2, N'B2'),
(3, N'B2');

-- xe (6 dòng)
SET IDENTITY_INSERT xe ON;
INSERT INTO xe (id, ma_xe, nhom_xe_id, hang_san_xuat, dong_xe, nam_san_xuat, bien_so, trang_thai, so_km_hien_tai, tinh_trang_pin, ghi_chu, ngay_tao) VALUES
(1, N'XE003', 1, N'VinFast', N'VF 6', 2024, N'66A-345.67', N'DANG_BAO_TRI', 8000, 40.00, NULL, '2026-10-22 22:11:59'),
(3, N'XE001', 1, N'VinFast', N'VF e34', 2023, N'66A-123.45', N'SAN_SANG', 12300, 0.00, NULL, '2026-10-22 22:11:59'),
(4, N'XE005', 2, N'Hyundai', N'Accent', 2023, N'66A-567.89', N'SAN_SANG', 18000, NULL, NULL, '2026-10-22 22:11:59'),
(5, N'XE004', 2, N'Toyota', N'Vios', 2022, N'66A-456.78', N'SAN_SANG', 30000, NULL, NULL, '2026-10-22 22:11:59'),
(6, N'XE006', 3, N'Toyota', N'Innova', 2022, N'66A-678.90', N'SAN_SANG', 42000, NULL, NULL, '2026-10-22 22:11:59'),
(2, N'XE002', 1, N'VinFast', N'VF 5 Plus', 2024, N'66A-234.56', N'SAN_SANG', 5000, 88.00, NULL, '2026-10-22 22:11:59');
SET IDENTITY_INSERT xe OFF;

-- anh_xe: (bảng rỗng trong CSDL cũ)
-- phieu_thue (1 dòng)
SET IDENTITY_INSERT phieu_thue ON;
INSERT INTO phieu_thue (id, ma_phieu, khach_hang_id, xe_id, nhan_vien_id, thoi_diem_nhan, thoi_diem_hen_tra, so_ngay_thue, so_km_nhan, tinh_trang_pin_nhan, don_gia_ngay, km_toi_da_moi_ngay, phi_vuot_km, phi_tre_gio, tien_coc, phan_tram_giam, trang_thai, ghi_chu, ngay_tao) VALUES
(68, N'PT20261028-143656', 2, 3, 2, '2026-10-28 08:11:00', '2026-10-30 08:11:00', 2, 12000, 95.00, 800000, 200, 2000, 80000, 5000000, 0.00, N'DA_TRA', NULL, '2026-10-27 08:11:50');
SET IDENTITY_INSERT phieu_thue OFF;

-- tra_xe (1 dòng)
SET IDENTITY_INSERT tra_xe ON;
INSERT INTO tra_xe (id, phieu_thue_id, nhan_vien_id, thoi_diem_tra_thuc_te, so_km_tra, km_da_di, so_gio_tre, km_vuot, tien_thue, phi_vuot_km, phi_tre, tong_truoc_giam, tien_giam, tong_phai_tra, xe_hu_hong, tinh_trang_pin_tra, ghi_chu, ngay_tao) VALUES
(29, 68, 2, '2026-10-29 08:54:00', 12300, 300, 0, 0, 1600000, 0, 0, 1600000, 0, 1600000, 0, 0.00, NULL, '2026-10-27 09:14:33');
SET IDENTITY_INSERT tra_xe OFF;

-- thanh_toan: (bảng rỗng trong CSDL cũ)
-- bao_tri (1 dòng)
SET IDENTITY_INSERT bao_tri ON;
INSERT INTO bao_tri (id, xe_id, nhan_vien_id, loai, mo_ta, ngay_bat_dau, ngay_ket_thuc, chi_phi, trang_thai) VALUES
(1, 1, 2, N'DINH_KY', N'Bảo dưỡng định kỳ và kiểm tra pin', '2026-10-22', NULL, 0, N'DANG_THUC_HIEN');
SET IDENTITY_INSERT bao_tri OFF;

GO

/* ================ 6. BỔ SUNG: TÀI KHOẢN ĐĂNG NHẬP MẪU ================
   (KHÔNG có trong CSDL cũ - bảng tai_khoan cũ rỗng. Thêm để làm chức năng đăng nhập.)
   mat_khau_hash = SHA-256 của chuỗi Unicode (UTF-16), viết hoa, dạng hex 64 ký tự.
     admin    / Admin@123    -> nhân viên 1 (quản lý)
     nhanvien / NhanVien@123 -> nhân viên 2
   Không dùng thì xóa phần này đi. */
SET IDENTITY_INSERT tai_khoan ON;
INSERT INTO tai_khoan (id, nhan_vien_id, ten_dang_nhap, mat_khau_hash, vai_tro) VALUES
(1, 1, 'admin',    CONVERT(NVARCHAR(MAX), HASHBYTES('SHA2_256', N'Admin@123'),    2), 'ADMIN'),
(2, 2, 'nhanvien', CONVERT(NVARCHAR(MAX), HASHBYTES('SHA2_256', N'NhanVien@123'), 2), 'NHAN_VIEN');
SET IDENTITY_INSERT tai_khoan OFF;
GO

/* ====================== 7. KIỂM TRA SAU KHI CHẠY ====================== */
SELECT 'hang_gplx' AS bang, COUNT(*) AS so_dong FROM hang_gplx UNION ALL
SELECT 'hang_thanh_vien', COUNT(*) FROM hang_thanh_vien UNION ALL
SELECT 'nhan_vien',       COUNT(*) FROM nhan_vien       UNION ALL
SELECT 'tai_khoan',       COUNT(*) FROM tai_khoan       UNION ALL
SELECT 'khach_hang',      COUNT(*) FROM khach_hang      UNION ALL
SELECT 'gplx_khach_hang', COUNT(*) FROM gplx_khach_hang UNION ALL
SELECT 'nhom_xe',         COUNT(*) FROM nhom_xe         UNION ALL
SELECT 'nhom_xe_gplx',    COUNT(*) FROM nhom_xe_gplx    UNION ALL
SELECT 'xe',              COUNT(*) FROM xe              UNION ALL
SELECT 'anh_xe',          COUNT(*) FROM anh_xe          UNION ALL
SELECT 'phieu_thue',      COUNT(*) FROM phieu_thue      UNION ALL
SELECT 'tra_xe',          COUNT(*) FROM tra_xe          UNION ALL
SELECT 'thanh_toan',      COUNT(*) FROM thanh_toan      UNION ALL
SELECT 'bao_tri',         COUNT(*) FROM bao_tri;
GO

/* --- Thử trigger chống trùng lịch: bỏ comment, chạy TỪNG câu một ---
-- Câu 1: chạy được
INSERT INTO phieu_thue (ma_phieu, khach_hang_id, xe_id, nhan_vien_id, thoi_diem_nhan, thoi_diem_hen_tra,
                        so_ngay_thue, so_km_nhan, don_gia_ngay, tien_coc)
VALUES ('TEST-1', 2, 4, 2, '2026-11-20 08:00', '2026-11-22 08:00', 2, 18000, 650000, 3000000);
-- Câu 2: phải báo lỗi 50001 (trùng lịch xe 4)
INSERT INTO phieu_thue (ma_phieu, khach_hang_id, xe_id, nhan_vien_id, thoi_diem_nhan, thoi_diem_hen_tra,
                        so_ngay_thue, so_km_nhan, don_gia_ngay, tien_coc)
VALUES ('TEST-2', 3, 4, 2, '2026-11-21 08:00', '2026-11-23 08:00', 2, 18000, 650000, 3000000);
-- Dọn dẹp
DELETE FROM phieu_thue WHERE ma_phieu LIKE 'TEST-%';
--------------------------------------------------------------------- */
