using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Globalization;
namespace DtRentAspx.Models
{
    /// <summary>
    /// Dữ liệu một xe hiển thị trong danh sách ở trang chủ
    /// (gộp thông tin từ bảng xe, nhom_xe, anh_xe và số lượt thuê từ phieu_thue).
    /// </summary>
    public class XeNoiBatVM
    {
        private static readonly CultureInfo Vi = new CultureInfo("vi-VN");

        // ----- Dữ liệu lấy từ CSDL -----
        public int id { get; set; }
        public string ten_xe { get; set; }              // hãng + dòng xe
        public int nam_san_xuat { get; set; }
        public string bien_so { get; set; }
        public string ten_nhom { get; set; }
        public int so_cho { get; set; }
        public string loai_nhien_lieu { get; set; }     // DIEN | XANG | DAU
        public decimal gia_thue_ngay { get; set; }
        public int? km_toi_da_moi_ngay { get; set; }    // null = không giới hạn
        public int so_km_hien_tai { get; set; }
        public string trang_thai { get; set; }          // SAN_SANG | DANG_CHO_THUE | DANG_BAO_TRI
        public string duong_dan_anh { get; set; }       // ảnh chính, có thể null
        public int luot_thue { get; set; }

        // ----- Thuộc tính phục vụ hiển thị -----
        public string AnhUrl
        {
            get
            {
                return string.IsNullOrWhiteSpace(duong_dan_anh)
                    ? "~/Images/xe-placeholder.svg"
                    : duong_dan_anh;
            }
        }

        public string GiaHienThi { get { return gia_thue_ngay.ToString("N0", Vi) + " ₫"; } }

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

        public string KmGioiHanText
        {
            get
            {
                return km_toi_da_moi_ngay.HasValue
                    ? km_toi_da_moi_ngay.Value.ToString("N0", Vi) + " km/ngày"
                    : "Không giới hạn km";
            }
        }

        public string KmDaDiText { get { return so_km_hien_tai.ToString("N0", Vi) + " km"; } }

        public string LuotThueText { get { return luot_thue + " lượt thuê"; } }
    }
}