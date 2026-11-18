using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Globalization;

namespace DtRentAspx.Models
{
    public class LichThueVM
    {
        public string Tu { get; set; }
        public string Den { get; set; }
    }
    public class XeChiTietVM
    {
        private static readonly CultureInfo Vi = new CultureInfo("vi-VN");

        // ----- Thông tin xe -----
        public int id { get; set; }
        public string ma_xe { get; set; }
        public string ten_xe { get; set; }              // hãng + dòng xe
        public string hang_san_xuat { get; set; }
        public string dong_xe { get; set; }
        public int nam_san_xuat { get; set; }
        public string bien_so { get; set; }
        public string trang_thai { get; set; }          // SAN_SANG | DANG_CHO_THUE | DANG_BAO_TRI
        public int so_km_hien_tai { get; set; }
        public decimal? tinh_trang_pin { get; set; }
        public string ghi_chu { get; set; }
        public int luot_thue { get; set; }

        // ----- Thông tin nhóm xe (giá, điều kiện thuê) -----
        public string ten_nhom { get; set; }
        public int so_cho { get; set; }
        public string loai_nhien_lieu { get; set; }     // DIEN | XANG | DAU
        public string chinh_sach_gia { get; set; }
        public decimal gia_thue_ngay { get; set; }
        public int? km_toi_da_moi_ngay { get; set; }    // null = không giới hạn
        public decimal? phi_vuot_km { get; set; }
        public decimal phi_tre_gio { get; set; }
        public decimal tien_coc { get; set; }

        // ----- Danh sách kèm theo -----
        public List<string> DanhSachAnh { get; set; }       // luôn có ít nhất 1 phần tử
        public List<string> GplxYeuCau { get; set; }
        public List<LichThueVM> LichThue { get; set; }

        // ----- Thuộc tính phục vụ hiển thị -----
        public string GiaHienThi { get { return Tien(gia_thue_ngay); } }
        public string TienCocText { get { return Tien(tien_coc); } }
        public string PhiTreText { get { return Tien(phi_tre_gio) + " / giờ"; } }
        public string PhiVuotKmText
        {
            get { return phi_vuot_km.HasValue ? Tien(phi_vuot_km.Value) + " / km" : "Không áp dụng"; }
        }
        public string KmGioiHanText
        {
            get
            {
                return km_toi_da_moi_ngay.HasValue
                    ? km_toi_da_moi_ngay.Value.ToString("N0", Vi) + " km / ngày"
                    : "Không giới hạn";
            }
        }
        public string KmDaDiText { get { return so_km_hien_tai.ToString("N0", Vi) + " km"; } }
        public string LuotThueText { get { return luot_thue + " lượt thuê"; } }

        public string ChinhSachGiaText
        {
            get
            {
                switch (chinh_sach_gia)
                {
                    case "NGAY_CO_GIOI_HAN_KM": return "Tính theo ngày, có giới hạn km";
                    case "NGAY_KHONG_GIOI_HAN_KM": return "Tính theo ngày, không giới hạn km";
                    default: return chinh_sach_gia;
                }
            }
        }

        public string NhienLieuText
        {
            get
            {
                switch (loai_nhien_lieu)
                {
                    case "DIEN": return "Điện";
                    case "XANG": return "Xăng";
                    case "DAU": return "Dầu";
                    default: return loai_nhien_lieu;
                }
            }
        }

        public string TrangThaiText
        {
            get
            {
                switch (trang_thai)
                {
                    case "SAN_SANG": return "Sẵn sàng";
                    case "DANG_CHO_THUE": return "Đang cho thuê";
                    case "DANG_BAO_TRI": return "Bảo trì";
                    default: return trang_thai;
                }
            }
        }

        public string TrangThaiCss
        {
            get
            {
                switch (trang_thai)
                {
                    case "SAN_SANG": return "status-ready";
                    case "DANG_CHO_THUE": return "status-rented";
                    default: return "status-maint";
                }
            }
        }

        public bool SanSang { get { return trang_thai == "SAN_SANG"; } }
        public bool CoPin { get { return loai_nhien_lieu == "DIEN" && tinh_trang_pin.HasValue; } }
        public string PinText { get { return tinh_trang_pin.HasValue ? tinh_trang_pin.Value.ToString("0.##", Vi) + "%" : ""; } }
        public bool CoGhiChu { get { return !string.IsNullOrWhiteSpace(ghi_chu); } }
        public bool CoLich { get { return LichThue != null && LichThue.Count > 0; } }
        public bool CoGplx { get { return GplxYeuCau != null && GplxYeuCau.Count > 0; } }

        private static string Tien(decimal v) { return v.ToString("N0", Vi) + " ₫"; }
    }
}