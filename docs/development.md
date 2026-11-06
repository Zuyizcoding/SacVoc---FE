# Chạy và kiểm tra Flutter

## SDK và Java

Lockfile ghi tối thiểu Flutter 3.38.4 và Dart 3.10.3, nhưng các package được SDK pin còn phụ thuộc bản Flutter cụ thể. Đợt refactor dùng **Flutter 3.41.5 / Dart 3.11.3**, khớp lockfile hiện tại. Chạy `flutter pub get --enforce-lockfile` để tránh tự thay đổi các phiên bản đã khóa.

Dùng JDK 17 và Android SDK có build tools/platform cần thiết. Không commit đường dẫn JDK của máy vào Gradle. Trong PowerShell có thể cấu hình cho phiên làm việc:

```powershell
$env:JAVA_HOME = 'C:\duong-dan-den-jdk-17'
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
flutter doctor -v
flutter pub get --enforce-lockfile
```

## Chọn backend

Khởi động backend trước, sau đó chạy từ thư mục frontend:

```powershell
# Android emulator: mặc định truy cập máy host qua 10.0.2.2
flutter run

# Thiết bị thật cùng mạng
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

Thay IP bằng địa chỉ máy chạy backend; backend cần listen `0.0.0.0`. Khi đổi URL phải chạy lại ứng dụng với define tương ứng. Các endpoint tập trung ở `ApiConstants`.

## Kiểm tra trước khi hoàn thành thay đổi

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
flutter build apk --debug --no-pub
```

Tests dùng model mẫu, repository giả hoặc Dio interceptor giả; không yêu cầu backend, khóa Gemini hay ảnh thật. Controller tests kiểm tra loading/data/error và refresh history; widget tests kiểm tra kết quả live/demo.

APK debug ở `build/app/outputs/flutter-apk/app-debug.apk`. Kiểm tra màn home, F1, F2, history, danh sách/chi tiết outfit và banner demo sau khi đổi widget dùng chung.

## Troubleshooting

- Không nhận lệnh `flutter`: thêm thư mục `bin` của SDK vào PATH và mở lại terminal.
- `--enforce-lockfile` thất bại: dùng SDK tương thích như bản kiểm chứng ở trên; không chạy upgrade để che lỗi môi trường.
- Gradle không tìm thấy Java: kiểm tra `JAVA_HOME`, `java -version`, thông tin trong `flutter doctor -v`.
- Lỗi Android licenses/platform: hoàn tất Android SDK setup qua Android Studio/SDK manager rồi kiểm tra lại doctor.
- Không kết nối API: emulator dùng `10.0.2.2`, thiết bị thật dùng IP máy host; kiểm tra `/health` và firewall.
- Quota AI: app có thể nhận kết quả demo; kiểm tra banner và `analysis_source` thay vì hiểu đó là lỗi UI.
- Thiếu F1/F2: hoàn thành bước còn thiếu trên cùng thiết bị trước khi mở F3.
