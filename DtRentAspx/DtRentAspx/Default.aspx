<%@ Page Title="Trang chủ" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="DtRentAspx.Default" %>
<%@ MasterType VirtualPath="~/Site.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
 
<%-- ================= ẢNH BÌA (toàn chiều rộng) ================= --%>
<asp:Content ID="ContentHero" ContentPlaceHolderID="HeroContent" runat="server">
    <div id="carouselHome" class="carousel slide carousel-fade hero-carousel" data-bs-ride="carousel">
 
        <div class="carousel-indicators">
            <button type="button" data-bs-target="#carouselHome" data-bs-slide-to="0" class="active" aria-current="true" aria-label="Ảnh 1"></button>
            <button type="button" data-bs-target="#carouselHome" data-bs-slide-to="1" aria-label="Ảnh 2"></button>
            <button type="button" data-bs-target="#carouselHome" data-bs-slide-to="2" aria-label="Ảnh 3"></button>
        </div>
 
        <div class="carousel-inner">
            <div class="carousel-item active">
                <img runat="server" src="~/Images/Carousel1.png" alt="BMW M3" class="d-block w-100" />
                <div class="carousel-caption">
                    <h3>BMW M3</h3>
                    <p>Hiệu năng lái thuần khiết</p>
                </div>
            </div>
            <div class="carousel-item">
                <img runat="server" src="~/Images/Carousel2.png" alt="Rolls-Royce Ghost" class="d-block w-100" />
                <div class="carousel-caption">
                    <h3>Rolls-Royce Ghost</h3>
                    <p>Sang trọng nhẹ nhàng, thanh lịch vượt thời gian</p>
                </div>
            </div>
            <div class="carousel-item">
                <img runat="server" src="~/Images/Carousel3.png" alt="Mercedes-Benz C-Class" class="d-block w-100" />
                <div class="carousel-caption">
                    <h3>Mercedes-Benz C-Class</h3>
                    <p>Thanh lịch vô song trong bóng đêm</p>
                </div>
            </div>
        </div>
 
        <button class="carousel-control-prev" type="button" data-bs-target="#carouselHome" data-bs-slide="prev">
            <span class="carousel-control-prev-icon" aria-hidden="true"></span>
            <span class="visually-hidden">Ảnh trước</span>
        </button>
        <button class="carousel-control-next" type="button" data-bs-target="#carouselHome" data-bs-slide="next">
            <span class="carousel-control-next-icon" aria-hidden="true"></span>
            <span class="visually-hidden">Ảnh sau</span>
        </button>
    </div>
</asp:Content>
 
<%-- ================= NỘI DUNG CHÍNH + CỘT BÊN PHẢI ================= --%>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row g-4">
 
        <%-- ----- Cột trái: giới thiệu, chức năng, bộ lọc ----- --%>
        <div class="col-lg-8">
 
            <div class="hero-intro p-4 p-md-5 mb-4">
                <h1 class="h2 fw-bold mb-2">Hệ thống cho thuê xe ô tô TX-Rent</h1>
                <p class="lead text-muted mb-4">Quản lý xe, khách hàng, phiếu thuê, trả xe và thanh toán.</p>
                <a runat="server" href="~/Xe.aspx" class="btn btn-primary btn-lg me-2 mb-2">Xem danh sách xe</a>
                <a runat="server" href="~/LapPhieuThue.aspx" class="btn btn-outline-dark btn-lg mb-2">Lập phiếu thuê</a>
            </div>

            <%-- ================= PHẦN DANH SÁCH XE THEO BỘ LỌC ================= --%>
            <asp:UpdatePanel ID="upDanhSach" runat="server">
                <ContentTemplate>
                    <div class="d-flex justify-content-between align-items-end mb-3" id="khuDanhSachXe">
                        <h2 class="h5 section-title mb-0">Xem nhanh danh sách xe</h2>
                        <span class="text-muted small"><asp:Label ID="lblKetQua" runat="server" /></span>
                    </div>
 
                    <%-- ================= BỘ LỌC ================= --%>
                    <asp:Panel ID="pnlLoc" runat="server" DefaultButton="btnTim" CssClass="card dt-card mb-3">
                        <div class="card-body">
                            <div class="row g-3">
 
                                <div class="col-md-4">
                                    <asp:Label runat="server" AssociatedControlID="txtTuKhoa" CssClass="form-label small fw-semibold">Tìm xe</asp:Label>
                                    <asp:TextBox ID="txtTuKhoa" runat="server" CssClass="form-control"
                                                 placeholder="Hãng, dòng xe hoặc biển số" MaxLength="50" />
                                </div>
 
                                <div class="col-md-4">
                                    <asp:Label runat="server" AssociatedControlID="ddlSapXep" CssClass="form-label small fw-semibold">Sắp xếp theo</asp:Label>
                                    <asp:DropDownList ID="ddlSapXep" runat="server" CssClass="form-select"
                                                      AutoPostBack="true" OnSelectedIndexChanged="LocThayDoi">
                                        <asp:ListItem Value="thue_nhieu" Selected="True">Thuê nhiều nhất</asp:ListItem>
                                        <asp:ListItem Value="gia_giam">Giá: cao đến thấp</asp:ListItem>
                                        <asp:ListItem Value="gia_tang">Giá: thấp đến cao</asp:ListItem>
                                        <asp:ListItem Value="moi_nhat">Đời xe mới nhất</asp:ListItem>
                                        <asp:ListItem Value="it_km">Ít km nhất</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
 
                                <div class="col-md-4">
                                    <asp:Label runat="server" AssociatedControlID="ddlNhomXe" CssClass="form-label small fw-semibold">Nhóm xe</asp:Label>
                                    <asp:DropDownList ID="ddlNhomXe" runat="server" CssClass="form-select"
                                                      AppendDataBoundItems="true" AutoPostBack="true" OnSelectedIndexChanged="LocThayDoi"
                                                      ItemType="DtRentAspx.Models.nhom_xe" SelectMethod="GetNhomXe"
                                                      DataTextField="ten" DataValueField="id">
                                        <asp:ListItem Value="0">Tất cả nhóm xe</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
 
                                <div class="col-md-4">
                                    <asp:Label runat="server" AssociatedControlID="ddlNhienLieu" CssClass="form-label small fw-semibold">Nhiên liệu</asp:Label>
                                    <asp:DropDownList ID="ddlNhienLieu" runat="server" CssClass="form-select"
                                                      AutoPostBack="true" OnSelectedIndexChanged="LocThayDoi">
                                        <asp:ListItem Value="" Selected="True">Tất cả</asp:ListItem>
                                        <asp:ListItem Value="DIEN">Điện</asp:ListItem>
                                        <asp:ListItem Value="XANG">Xăng</asp:ListItem>
                                        <asp:ListItem Value="DAU">Dầu</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
 
                                <div class="col-md-4 d-flex align-items-end">
                                    <asp:CheckBox ID="chkSanSang" runat="server" Text="Chỉ hiện xe sẵn sàng" CssClass="dt-check pb-2"
                                                  AutoPostBack="true" OnCheckedChanged="LocThayDoi" />
                                </div>
 
                                <div class="col-md-4 d-flex align-items-end gap-2">
                                    <asp:Button ID="btnTim" runat="server" Text="Tìm" CssClass="btn btn-primary" OnClick="LocThayDoi" />
                                    <asp:Button ID="btnDatLai" runat="server" Text="Đặt lại" CssClass="btn btn-outline-dark" OnClick="btnDatLai_Click" />
                                </div>
 
                            </div>
                        </div>
                    </asp:Panel>
 
                    <%-- ================= DANH SÁCH XE (5 xe / trang) ================= --%>
                    <asp:ListView ID="lvXe" runat="server" ItemType="DtRentAspx.Models.XeNoiBatVM"
                                  SelectMethod="GetXeNoiBat" OnDataBound="lvXe_DataBound"
                                  OnPagePropertiesChanged="lvXe_PagePropertiesChanged" 
                                  OnItemCommand="lvXe_ItemCommand">
 
                        <LayoutTemplate>
                            <asp:PlaceHolder ID="itemPlaceholder" runat="server" />
                        </LayoutTemplate>
 
                        <ItemTemplate>
                            <div class="card xe-card mb-3">
                                <div class="row g-0">
 
                                    <%-- Ảnh xe + nhãn trạng thái --%>
                                    <div class="col-md-4 xe-card-img">
                                        <img src="<%# ResolveUrl(Item.AnhUrl) %>" alt="<%#: Item.ten_xe %>" loading="lazy"
                                             onerror="this.onerror=null;this.src='<%# ResolveUrl("~/Images/xe-placeholder.svg") %>';" />
                                        <span class="badge xe-status <%# Item.TrangThaiCss %>"><%#: Item.TrangThaiText %></span>
                                    </div>
 
                                    <%-- Thông tin --%>
                                    <div class="col-md-8">
                                        <div class="card-body d-flex flex-column h-100">
 
                                            <div class="d-flex justify-content-between align-items-start gap-3">
                                                <div>
                                                    <h5 class="card-title mb-1"><%#: Item.ten_xe %></h5>
                                                    <div class="text-muted small"><%#: Item.ten_nhom %> &middot; Biển số <%#: Item.bien_so %></div>
                                                </div>
                                                <div class="text-end flex-shrink-0">
                                                    <div class="xe-price"><%#: Item.GiaHienThi %></div>
                                                    <div class="small text-muted">mỗi ngày</div>
                                                </div>
                                            </div>
 
                                            <div class="my-3">
                                                <span class="xe-chip"><%#: Item.so_cho %> chỗ</span>
                                                <span class="xe-chip"><%#: Item.NhienLieuText %></span>
                                                <span class="xe-chip">Đời <%#: Item.nam_san_xuat %></span>
                                                <span class="xe-chip"><%#: Item.KmGioiHanText %></span>
                                                <span class="xe-chip">Đã đi <%#: Item.KmDaDiText %></span>
                                            </div>
 
                                            <div class="mt-auto d-flex flex-wrap align-items-center gap-2">
                                                <span class="xe-rented"><%#: Item.LuotThueText %></span>
                                                <div class="ms-auto d-flex gap-2">
                                                    <asp:Button runat="server" CssClass="btn btn-outline-dark btn-sm" Text="Xem chi tiết"
                                                                CommandName="XemChiTiet" CommandArgument='<%# Item.id %>' CausesValidation="false" />
                                                    <asp:HyperLink runat="server" CssClass="btn btn-primary btn-sm"
                                                                   NavigateUrl='<%# "~/LapPhieuThue.aspx?xe=" + Item.id %>'
                                                                   Visible='<%# Item.trang_thai == "SAN_SANG" %>'>Thuê xe</asp:HyperLink>
                                                </div>
                                            </div>
 
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
 
                        <EmptyDataTemplate>
                            <div class="alert alert-secondary mb-0">Không có xe nào phù hợp với bộ lọc. Hãy thử đổi tiêu chí hoặc bấm "Đặt lại".</div>
                        </EmptyDataTemplate>
                    </asp:ListView>
 
                    <%-- ================= PHÂN TRANG ================= --%>
                    <div id="pagerWrap" runat="server" class="d-none">
                        <asp:DataPager ID="dpXe" runat="server" PagedControlID="lvXe" PageSize="5" CssClass="dt-pager">
                            <Fields>
                                <asp:NextPreviousPagerField ButtonType="Link"
                                    ShowFirstPageButton="True" ShowPreviousPageButton="True"
                                    ShowNextPageButton="False" ShowLastPageButton="False"
                                    FirstPageText="&laquo;" PreviousPageText="&lsaquo;" />
                                <asp:NumericPagerField ButtonCount="5"
                                    CurrentPageLabelCssClass="current" NumericButtonCssClass="num" />
                                <asp:NextPreviousPagerField ButtonType="Link"
                                    ShowFirstPageButton="False" ShowPreviousPageButton="False"
                                    ShowNextPageButton="True" ShowLastPageButton="True"
                                    NextPageText="&rsaquo;" LastPageText="&raquo;" />
                            </Fields>
                        </asp:DataPager>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
 
        <%-- ----- Cột phải: thông tin hỗ trợ ----- --%>
        <aside class="col-lg-4">
 
            <div class="card dt-card mb-3">
                <img runat="server" src="~/Images/quangcao-txrent.jpg" class="card-img-top"
                     alt="TX-Rent - dịch vụ cho thuê xe ô tô" style="height: 350px; object-fit: cover;" />
 
                <div class="card-body">
                    <h5 class="card-title fw-bold mb-2">TX-Rent &ndash; Thuê xe dễ dàng, đi xa an tâm</h5>
                    <p class="card-text small text-muted">
                        Dịch vụ cho thuê xe ô tô tự lái theo ngày, thủ tục nhanh gọn tại quầy,
                        chi phí rõ ràng ngay từ đầu.
                    </p>
 
                    <ul class="list-unstyled small mb-3">
                        <li class="d-flex gap-2 mb-2">
                            <span class="fw-bold" style="color: var(--dt-gold-dark);">&#10003;</span>
                            <span><strong>Đa dạng nhóm xe:</strong> xe điện, xe xăng 5 chỗ và SUV 7 chỗ cho mọi chuyến đi.</span>
                        </li>
                        <li class="d-flex gap-2 mb-2">
                            <span class="fw-bold" style="color: var(--dt-gold-dark);">&#10003;</span>
                            <span><strong>Giá minh bạch:</strong> giới hạn km, phí phát sinh và tiền cọc được nêu rõ trước khi thuê.</span>
                        </li>
                        <li class="d-flex gap-2 mb-2">
                            <span class="fw-bold" style="color: var(--dt-gold-dark);">&#10003;</span>
                            <span><strong>Ưu đãi thành viên:</strong> khách thân thiết được giảm giá theo hạng.</span>
                        </li>
                        <li class="d-flex gap-2">
                            <span class="fw-bold" style="color: var(--dt-gold-dark);">&#10003;</span>
                            <span><strong>Xe luôn sẵn sàng:</strong> được kiểm tra và bảo dưỡng định kỳ.</span>
                        </li>
                    </ul>
 
                    <a href="#khuDanhSachXe" class="btn btn-primary w-100 mb-2">Xem danh sách xe và thuê ngay</a>
                    <div class="text-center small text-muted">
                        Hotline <a href="tel:0969696969" class="fw-semibold">0969 696 969</a>
                    </div>
                </div>
            </div>

            <div class="card dt-card mb-3">
                <div class="card-header">Quy trình thuê xe</div>
                <ol class="list-group list-group-numbered list-group-flush">
                    <li class="list-group-item">Chọn xe phù hợp theo nhóm xe và giá thuê</li>
                    <li class="list-group-item">Lập phiếu thuê và đặt cọc</li>
                    <li class="list-group-item">Nhận xe, ghi nhận số km ban đầu</li>
                    <li class="list-group-item">Trả xe, tính phí và thanh toán</li>
                </ol>
            </div>
 
            <div class="card dt-card mb-3">
                <div class="card-header">Chính sách giá và phí</div>
                <ul class="list-group list-group-flush">
                    <li class="list-group-item">Giá thuê tính theo ngày, theo từng nhóm xe</li>
                    <li class="list-group-item">Có giới hạn km mỗi ngày; vượt km tính phí theo km</li>
                    <li class="list-group-item">Trả xe trễ tính phí theo giờ</li>
                    <li class="list-group-item">Giảm giá theo hạng thành viên</li>
                </ul>
            </div>
 
            <div class="card dt-card mb-3">
                <div class="card-header">Giấy tờ cần chuẩn bị</div>
                <ul class="list-group list-group-flush">
                    <li class="list-group-item">Căn cước công dân</li>
                    <li class="list-group-item">Giấy phép lái xe, hạng phù hợp với nhóm xe thuê</li>
                    <li class="list-group-item">Tiền cọc theo quy định của từng nhóm xe</li>
                </ul>
            </div>
        </aside>
    </div>
</asp:Content>
 
