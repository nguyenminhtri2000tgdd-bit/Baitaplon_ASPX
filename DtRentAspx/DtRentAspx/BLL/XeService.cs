using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using DtRentAspx.Models;

namespace DtRentAspx.BLL
{
    /// <summary>Nghiệp vụ liên quan đến xe. Dùng chung cho mọi trang (panel chi tiết xe ở master page...).</summary>
    public static class XeService
    {
        /// <summary>
        /// Lấy đầy đủ thông tin một xe để hiển thị. Trả về null nếu không có xe với mã đó.
        /// Toàn bộ dữ liệu được đọc xong trước khi trả về, nên có thể giải phóng DbContext ngay sau khi gọi.
        /// </summary>
        public static XeChiTietVM LayChiTiet(DtRentContext db, int maXe)
        {
            var x = db.xes.FirstOrDefault(e => e.id == maXe);
            if (x == null) return null;

            // Ảnh: ảnh chính đứng đầu; chưa có ảnh nào thì dùng ảnh mặc định
            var anh = x.anh_xe
                       .OrderByDescending(a => a.la_anh_chinh)
                       .ThenBy(a => a.id)
                       .Select(a => a.duong_dan)
                       .ToList();
            if (anh.Count == 0) anh.Add("~/Images/xe-placeholder.svg");

            // Hạng giấy phép lái xe mà nhóm xe này yêu cầu
            var gplx = x.nhom_xe.hang_gplx
                        .OrderBy(h => h.ma)
                        .Select(h => h.ma + " \u2013 " + h.mo_ta)
                        .ToList();

            // Lịch các phiếu đang thuê chưa đến hạn trả
            DateTime bayGio = DateTime.Now;
            var lich = db.phieu_thue
                         .Where(p => p.xe_id == maXe && p.trang_thai == "DANG_THUE" && p.thoi_diem_hen_tra >= bayGio)
                         .OrderBy(p => p.thoi_diem_nhan)
                         .Select(p => new { p.thoi_diem_nhan, p.thoi_diem_hen_tra })
                         .ToList()
                         .Select(p => new LichThueVM
                         {
                             Tu = p.thoi_diem_nhan.ToString("dd/MM/yyyy HH:mm"),
                             Den = p.thoi_diem_hen_tra.ToString("dd/MM/yyyy HH:mm")
                         })
                         .ToList();

            int luotThue = db.phieu_thue.Count(p => p.xe_id == maXe && p.trang_thai != "DA_HUY");

            return new XeChiTietVM
            {
                id = x.id,
                ma_xe = x.ma_xe,
                ten_xe = x.hang_san_xuat + " " + x.dong_xe,
                hang_san_xuat = x.hang_san_xuat,
                dong_xe = x.dong_xe,
                nam_san_xuat = x.nam_san_xuat,
                bien_so = x.bien_so,
                trang_thai = x.trang_thai,
                so_km_hien_tai = x.so_km_hien_tai,
                tinh_trang_pin = x.tinh_trang_pin,
                ghi_chu = x.ghi_chu,
                luot_thue = luotThue,

                ten_nhom = x.nhom_xe.ten,
                so_cho = x.nhom_xe.so_cho,
                loai_nhien_lieu = x.nhom_xe.loai_nhien_lieu,
                chinh_sach_gia = x.nhom_xe.chinh_sach_gia,
                gia_thue_ngay = x.nhom_xe.gia_thue_ngay,
                km_toi_da_moi_ngay = x.nhom_xe.km_toi_da_moi_ngay,
                phi_vuot_km = x.nhom_xe.phi_vuot_km,
                phi_tre_gio = x.nhom_xe.phi_tre_gio,
                tien_coc = x.nhom_xe.tien_coc,

                DanhSachAnh = anh,
                GplxYeuCau = gplx,
                LichThue = lich
            };
        }
    }
}