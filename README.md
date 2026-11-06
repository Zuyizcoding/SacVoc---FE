# Sắc Vóc — Mobile App (Flutter)

Ứng dụng Android **Sắc Vóc** — phân tích màu sắc cá nhân, dáng người và gợi ý trang phục phù hợp, kết nối API backend FastAPI.

| Thành phần | Công nghệ |
|------------|-----------|
| Framework | Flutter 3.x (Dart ≥ 3.3) |
| State | Riverpod |
| Routing | GoRouter |
| HTTP | Dio |
| Device ID | `device_info_plus` + SHA256 → header `X-Device-ID` |

Repo backend: [`SacVoc---BE`](../SacVoc---BE).

---

## Luồng người dùng

1. **F1 — Màu sắc** — chụp/chọn selfie → nhận mùa sắc, palette, lời khuyên.
2. **F2 — Dáng người** — chụp/chọn ảnh toàn thân → nhận dáng + gợi ý form.
3. **F3 — Outfit** — gợi ý 6 set đồ theo F1+F2 và dịp (`daily`, `work`, `party`, `date`).
4. **Lịch sử / Hồ sơ** — xem lại kết quả đã phân tích trên thiết bị.

Khi backend ở chế độ `analysis_source: degraded_demo` (AI quá tải), app hiển thị banner cảnh báo.

---

## Cấu trúc mã nguồn

```text
lib/
  core/
    constants/api_constants.dart   # Base URL & API paths
    router/app_router.dart         # GoRouter
    widgets/                       # UI dùng chung
  features/
    analysis/                      # F1, F2, history
    outfit/                        # F3, chi tiết outfit
```

Clean Architecture nhẹ: `domain` / `data` (repository) / `presentation` (screen + Riverpod controller).

---

## Yêu cầu

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable, SDK ≥ 3.3)
- Android SDK + emulator hoặc thiết bị thật
- Backend **Sắc Vóc API** đang chạy (mặc định port `8000`)

---

## Cài đặt & chạy

### 1. Cài dependency

```bash
cd SacVoc---FE
flutter pub get
```

### 2. Cấu hình API

Truyền URL qua `flutter run --dart-define=API_BASE_URL=<url>`. Giá trị mặc định vẫn là URL Android emulator:

| Môi trường | `baseUrl` gợi ý |
|------------|----------------|
| Android Emulator | `http://10.0.2.2:8000` |
| Thiết bị thật (cùng Wi‑Fi) | `http://<IP-máy-chạy-BE>:8000` |
| Backend deploy (Railway, v.v.) | `https://<domain-của-be>` |

### 3. Chạy backend trước

Xem hướng dẫn trong [README backend](../SacVoc---BE/README.md).

```bash
# Ví dụ
cd ../SacVoc---BE
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 4. Chạy app

```bash
flutter devices
flutter run -d <device-id>
```

**Emulator lag do snapshot cũ** — cold boot:

```bash
emulator -avd <tên_avd> -no-snapshot-load
```

### 5. Build APK (debug)

```bash
flutter build apk --debug
```

File: `build/app/outputs/flutter-apk/app-debug.apk`  
Trên máy thật cần đổi `baseUrl` sang IP/domain public, không dùng `10.0.2.2`.

---

## API sử dụng

| Endpoint | Màn hình |
|----------|----------|
| `POST /api/v1/analyze/color` | Phân tích màu |
| `POST /api/v1/analyze/body` | Phân tích dáng |
| `GET /api/v1/analyze/history` | Lịch sử / hồ sơ |
| `GET /api/v1/outfits/recommend` | Danh sách outfit |
| `GET /api/v1/outfits/{id}` | Chi tiết + Shopee |
| `GET /health` | Kiểm tra BE khi cần |

Mọi request phân tích / gợi ý gửi header:

```http
X-Device-ID: <sha256-64-hex>
```

---

## Chạy test

```bash
flutter test
```

---

## Ghi chú phát triển

- Platform chính: **Android**. Thư mục `windows.__disabled_for_android__/` không dùng cho build.
- Không commit: `build/`, `.dart_tool/`, file APK.
- Cần quyền camera / thư viện ảnh trên thiết bị khi test F1/F2.

---

## License / nhóm

Dự án môn học **CS4153** — UIT. Liên hệ nhóm phát triển qua repository Git của course.

## Dành cho người mới

Đọc [onboarding và khái niệm Flutter/Riverpod](docs/onboarding.md), rồi làm theo [setup/tests/build](docs/development.md). SDK kiểm chứng với lockfile hiện tại: Flutter 3.41.5 / Dart 3.11.3. Dùng `flutter pub get --enforce-lockfile`. Các view kết quả dùng chung ở `lib/features/analysis/presentation/widgets/`; home và splash ở feature `home`.
