# Bắt đầu đọc frontend

Nếu đã biết Dart nhưng chưa quen Flutter, đọc phần khái niệm dưới đây trước, rồi lần theo một lần bấm “Phân tích màu sắc”. [Bản đồ toàn hệ thống](../../SacVoc---BE/docs/architecture.md) có sơ đồ F1, F2, F3, history và fallback.

## Khái niệm qua code thật

| Khái niệm | Cách project dùng |
|---|---|
| Widget | Mô tả giao diện từ dữ liệu hiện tại. Flutter gọi lại `build` khi cần cập nhật. |
| StatefulWidget | Giữ trạng thái cục bộ như đang chọn ảnh và file gần nhất. Không tự giữ bản sao kết quả API. |
| ProviderScope | Được đặt ở `main.dart`, tạo phạm vi quản lý dependencies và state của Riverpod. |
| Provider | Cung cấp một dependency, ví dụ Dio hoặc repository; tests có thể override bằng bản giả. |
| AsyncNotifier / AsyncValue | Controller cập nhật ba trạng thái loading, data, error. `data(null)` nghĩa là chưa phân tích. |
| `ref.watch` | Widget theo dõi provider; khi state đổi, giao diện đọc lại state mới. |
| `ref.read` | Lấy controller/repository để thực hiện hành động một lần, ví dụ khi bấm nút. |
| Repository | Chịu trách nhiệm gửi request, đọc lỗi và chuyển JSON thành model Dart. |
| Dio interceptor | Chạy trước request để thêm SHA256 device ID; screen không tự thêm header. |
| GoRouter | Ánh xạ URL của app như `/color`, `/history`, `/outfit/:id` thành screen. |
| `async` / `await` | Chờ thao tác như chọn ảnh hoặc gọi API mà không chặn giao diện. |

Ví dụ ở controller: `state = const AsyncValue.loading()` làm screen hiện loading. Sau `await repository.analyzeColor(file)`, controller gán kết quả hoặc lỗi. `ref.invalidate(analysisHistoryProvider)` khiến hồ sơ được đọc lại sau khi có phân tích mới.

## Thứ tự đọc

1. [main](../lib/main.dart): ProviderScope và MaterialApp.
2. [router](../lib/core/router/app_router.dart): route và hiệu ứng chuyển trang.
3. [home](../lib/features/home/presentation/home_screen.dart): F1/F2 đã có chưa và bước tiếp theo.
4. [ColorAnalysisScreen](../lib/features/analysis/presentation/color_analysis_screen.dart): chọn ảnh và gọi controller.
5. [controller](../lib/features/analysis/presentation/analysis_controller.dart): loading/data/error và cập nhật history.
6. [repository](../lib/features/analysis/data/analysis_repository.dart): multipart, JSON và lỗi.
7. [Dio client](../lib/core/network/dio_client.dart): URL, timeout và device ID.
8. [ColorResultView](../lib/features/analysis/presentation/widgets/color_result_view.dart): hiển thị model kết quả.

F2 đi cùng hướng, với `BodyResultView` và `PhotoQualityCard`. Hai controller vẫn riêng để đọc trọn một chức năng mà không cần lần qua controller generic.

## Một nơi sở hữu mỗi trách nhiệm

```text
Screen: chọn ảnh, haptic, thử lại, bố cục màn hình
  → Controller: quản lý state và gọi repository
    → Repository: API request/response và thông báo theo chức năng
      → Dio: transport, timeout, header thiết bị
```

`ApiErrorDetails` đọc cả lỗi trong envelope và `HTTPException.detail`; repository chọn thông báo phù hợp chức năng. `ApiResponse.errorCode` là chuỗi nullable, có thể nhận mã số cũ và chuyển thành chuỗi.

Màn phân tích và history dùng chung `ColorResultView`, `BodyResultView`, `PhotoQualityCard`, `AnalysisSourceBanner`. Khi sửa cách hiển thị kết quả, bắt đầu ở các widget này. Nội dung banner và dấu bullet là tham số để giữ cách hiển thị từng màn.

## F3 và history

`OutfitScreen` gọi `OutfitController.loadRecommendations()`, repository gửi `occasion` và `gender`. Backend yêu cầu cả F1/F2; `MissingAnalysisException` giữ thông tin thiếu màu hoặc dáng để UI hướng người dùng quay lại bước cần thiết. Danh sách một cột là `OutfitList`, chi tiết dùng provider theo ID.

`AnalysisHistoryController` đọc kết quả gần nhất khi được dùng. History screen refresh khi mở; phân tích thành công invalidate history. History gắn với device ID trong SharedPreferences, không phải tài khoản đăng nhập.

## Hiểu kết quả đúng cách

- `analysisSource == live`: ảnh đã đi qua suy luận AI.
- `degraded_demo`: backend dùng kết quả mẫu do quá tải/timeout; banner phải hiện ở cả màn phân tích và history.
- Confidence thể hiện độ chắc chắn sau điều chỉnh theo ảnh; không phải độ chính xác được xác nhận.
- Điểm chất lượng ảnh là heuristic về đầu vào. Điểm match outfit là điểm xếp hạng, không phải xác suất.
- Dù dữ liệu demo vẫn được lưu và có thể dùng cho F3, người dùng phải thấy nguồn kết quả rõ ràng.

## Khi sửa chức năng

Đọc [ba ví dụ thay đổi](../../SacVoc---BE/docs/change-recipes.md): thêm field kết quả, sửa nội dung UI và sửa quy tắc xếp hạng. Với field mới, luôn kiểm tra JSON cũ thiếu field và kết quả demo; với UI, kiểm tra cả screen phân tích và history.
