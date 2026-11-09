# Máy tính (kiểu Android) cho iPhone

App máy tính giao diện Material You giống Android:
- Xem toàn bộ phép tính dài cả khi đang gõ lẫn sau khi bấm `=`
- Chạm vào phép tính để đặt con trỏ và sửa giữa chừng
- Lịch sử, hàng phím khoa học, % kiểu Android
- Giao diện Sáng / Tối / Tự động, 5 tông màu

## Lấy file IPA

Mỗi lần đẩy code lên nhánh `main`, GitHub Actions tự build và tạo bản phát hành
trong mục **Releases** (file `MayTinh.ipa`). Muốn build lại thủ công: tab **Actions** →
**Build IPA** → **Run workflow**.

## Cài lên iPhone

File IPA chưa được ký, nên cần một công cụ ký lại bằng Apple ID của bạn:

- **Sideloadly** (Windows/Mac): cắm iPhone vào máy tính, kéo file IPA vào, đăng nhập Apple ID, bấm Start.
- **AltStore**: tương tự, có thể tự làm mới chữ ký qua Wi-Fi.

Với Apple ID miễn phí, chữ ký hết hạn sau 7 ngày — cần cài/làm mới lại.
Trên iPhone, lần đầu mở app: **Cài đặt → Cài đặt chung → Quản lý VPN & thiết bị** → tin cậy Apple ID của bạn.
Nếu iOS 16 trở lên, bật **Cài đặt → Quyền riêng tư & Bảo mật → Chế độ nhà phát triển**.

## Cấu trúc

- `App/index.html` — toàn bộ giao diện và logic máy tính
- `App/AppDelegate.swift` — vỏ app iOS (WKWebView, rung phản hồi, sao chép, màu thanh trạng thái)
- `project.yml` — cấu hình XcodeGen
- `.github/workflows/build-ipa.yml` — build IPA trên GitHub Actions
