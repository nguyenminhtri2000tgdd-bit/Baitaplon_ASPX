/* ============================================================================
   02 - DỮ LIỆU MẪU CHO DANH SÁCH XE Ở TRANG CHỦ      (CSDL: dt_rent)
   A) Thêm đường dẫn ảnh chính cho từng xe vào bảng anh_xe
   B) Thêm lịch sử thuê xe mẫu để sắp xếp "Thuê nhiều nhất" có kết quả khác nhau
   Chạy trong SSMS sau khi đã chạy file 01. Có thể chạy lại nhiều lần (không bị nhân đôi).
   ============================================================================ */
USE dt_rent;
GO

/* ---------- A. ẢNH XE ----------
   Mỗi xe có 1 ảnh chính, đường dẫn dạng  ~/Images/xe/<ma_xe>.jpg
   Bạn đặt ảnh vào thư mục Images/xe của project và ĐẶT TÊN FILE THEO MÃ XE:
       XE001.jpg  XE002.jpg  XE003.jpg  XE004.jpg  XE005.jpg  XE006.jpg
   Xe nào chưa có file ảnh sẽ tự hiện ảnh xe-placeholder.svg.            */
INSERT INTO anh_xe (xe_id, duong_dan, la_anh_chinh)
SELECT x.id, '~/Images/xe/' + x.ma_xe + '.jpg', 1
FROM   xe x
WHERE  NOT EXISTS (SELECT 1 FROM anh_xe a WHERE a.xe_id = x.id);
GO

/* Nếu ảnh của bạn là .png (hoặc .webp), chạy thêm câu lệnh sau (bỏ comment):
-- UPDATE anh_xe SET duong_dan = REPLACE(duong_dan, '.jpg', '.png');
*/

/* ---------- B. LỊCH SỬ THUÊ XE MẪU ----------
   Tạo các phiếu thuê đã trả (mã phiếu bắt đầu bằng DEMO-) kèm biên bản trả xe,
   số lượt thuê mỗi xe (chưa tính phiếu thật PT20261028-143656 của xe XE001):
       XE004 (Vios) 7   | XE005 (Accent) 5 | XE002 (VF 5 Plus) 4
       XE006 (Innova) 3 | XE001 (VF e34) 1 | XE003 (VF 6) 1               */
IF NOT EXISTS (SELECT 1 FROM phieu_thue WHERE ma_phieu LIKE 'DEMO-%')
BEGIN
    DECLARE @ke_hoach TABLE (ma_xe VARCHAR(20), so_luot INT);
    INSERT INTO @ke_hoach (ma_xe, so_luot) VALUES
        ('XE004', 7), ('XE005', 5), ('XE002', 4), ('XE006', 3), ('XE001', 1), ('XE003', 1);

    ;WITH so AS (
        SELECT TOP (10) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS k
        FROM sys.all_objects
    )
    INSERT INTO phieu_thue
        (ma_phieu, khach_hang_id, xe_id, nhan_vien_id, thoi_diem_nhan, thoi_diem_hen_tra,
         so_ngay_thue, so_km_nhan, don_gia_ngay, km_toi_da_moi_ngay, phi_vuot_km, phi_tre_gio,
         tien_coc, phan_tram_giam, trang_thai, ngay_tao)
    SELECT 'DEMO-' + RIGHT('0' + CAST(x.id AS VARCHAR(2)), 2) + '-' + CAST(s.k AS VARCHAR(2)),
           1 + ((x.id + s.k) % 4),                       -- khách hàng 1..4
           x.id,
           1 + (s.k % 2),                                -- nhân viên 1..2
           DATEADD(DAY, -(s.k * 9 + x.id * 2),     CAST('2026-10-20 08:00' AS DATETIME2(0))),
           DATEADD(DAY,  2 - (s.k * 9 + x.id * 2), CAST('2026-10-20 08:00' AS DATETIME2(0))),
           2,                                            -- thuê 2 ngày
           500 * s.k,
           n.gia_thue_ngay, n.km_toi_da_moi_ngay, n.phi_vuot_km, n.phi_tre_gio, n.tien_coc,
           0,
           'DA_TRA',
           DATEADD(DAY, -(s.k * 9 + x.id * 2) - 1, CAST('2026-10-20 08:00' AS DATETIME2(0)))
    FROM   @ke_hoach p
    JOIN   xe x      ON x.ma_xe = p.ma_xe
    JOIN   nhom_xe n ON n.id = x.nhom_xe_id
    JOIN   so s      ON s.k <= p.so_luot;

    -- Biên bản trả xe tương ứng: đi 300 km, trả đúng hạn, không phí phát sinh, không giảm giá
    INSERT INTO tra_xe
        (phieu_thue_id, nhan_vien_id, thoi_diem_tra_thuc_te, so_km_tra, km_da_di, so_gio_tre, km_vuot,
         tien_thue, phi_vuot_km, phi_tre, tong_truoc_giam, tien_giam, tong_phai_tra, xe_hu_hong, ngay_tao)
    SELECT t.id, t.nhan_vien_id, t.thoi_diem_hen_tra, t.so_km_nhan + 300, 300, 0, 0,
           t.don_gia_ngay * t.so_ngay_thue, 0, 0,
           t.don_gia_ngay * t.so_ngay_thue, 0,
           t.don_gia_ngay * t.so_ngay_thue,
           0, t.thoi_diem_hen_tra
    FROM   phieu_thue t
    WHERE  t.ma_phieu LIKE 'DEMO-%';
END
GO

/* ---------- KIỂM TRA: thứ hạng "Thuê nhiều nhất" ----------
   Kết quả đúng: XE004 7 | XE005 5 | XE002 4 | XE006 3 | XE001 2 | XE003 1        */
SELECT x.ma_xe, x.hang_san_xuat + N' ' + x.dong_xe AS ten_xe, COUNT(p.id) AS luot_thue
FROM   xe x
LEFT JOIN phieu_thue p ON p.xe_id = x.id AND p.trang_thai <> 'DA_HUY'
GROUP BY x.ma_xe, x.hang_san_xuat, x.dong_xe
ORDER BY luot_thue DESC, x.ma_xe;
GO

/* ---------- XÓA DỮ LIỆU MẪU LƯỢT THUÊ (khi nộp bài thật, bỏ comment rồi chạy) ----------
-- DELETE FROM tra_xe     WHERE phieu_thue_id IN (SELECT id FROM phieu_thue WHERE ma_phieu LIKE 'DEMO-%');
-- DELETE FROM phieu_thue WHERE ma_phieu LIKE 'DEMO-%';
------------------------------------------------------------------------------------------- */
