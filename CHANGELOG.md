# Nexus-Zalo — CHANGELOG

## [2.2.0] — 2026-11-24 (SePay Payment Polish)

### ✨ Tính năng mới & Cải tiến

| File | Thay đổi |
|------|---------|
| `public/layout.html` | Modal thanh toán: thêm nút copy (📋) cho STK và mã CK, QR loading skeleton, QR error state với nút Tải lại |
| `public/css/payment.css` | Thêm styles: `.btn-copy-inline`, `.payment-qr-skeleton`, `.payment-qr-error`, `.payment-footer`, `.payment-status-expired`, shimmer animation |
| `public/js/views/payment.js` | Thêm: copy-to-clipboard, QR load/error/retry logic, xử lý status EXPIRED, tách `_initQr()` |
| `src/services/payment.js` | Thêm: `getOrderList()`, `cancelOrder()`, auto-stop poller khi hết PENDING |
| `src/routes/payment.js` | Thêm dev endpoints: `GET /orders`, `DELETE /orders/:id`, `GET /poll-status` |

### 🐛 Sửa lỗi

| File | Lỗi | Fix |
|------|-----|-----|
| `src/services/payment.js` | Poller tiếp tục chạy ngay cả khi không còn order PENDING → lãng phí API call | Auto-stop khi pending.length = 0 |
| `public/js/views/payment.js` | Status EXPIRED không được xử lý → modal treo mãi | Thêm case EXPIRED: toast + close |

---

## [2.1.0] — 2026-11-23 (Bug fixes & Upgrade)

### 🐛 Sửa lỗi

| File | Lỗi | Fix |
|------|-----|-----|
| `public/js/monitor.js` | Sau page reload, dock hiện lại ngay cả khi không có job đang chạy | Ẩn dock khi `!job.id \|\| status === 'idle'` |
| `public/js/monitor.js` | Bấm "Dọn log" nhưng lần poll tiếp theo lại render logs trở lại | Thêm flag `_logCleared`; nếu true thì không ghi đè DOM logs |
| `public/js/monitor.js` | Toggle ▼/▲ bị ngược logic | Sửa lại điều kiện `isVisible` |
| `public/js/monitor.js` | Reload trang khi job đang chạy dở: monitor không tự poll | `update()` phát hiện `status === 'running'` → tự gọi `startPolling()` |
| `public/index.html` | Script load order: `monitor.js` load sau `router.js`, nhưng `ui-loader.js` gọi `ui:ready` trước khi `app.js` bind listener | Sắp xếp lại thứ tự: `api → ui → router → monitor → views → app → ui-loader` |
| `public/js/app.js` | Version hardcode `v2.0.0` trong `console.log` | Đọc từ `/api/health` động |
| `src/server.js` | Thiếu global error handler middleware → server crash nếu có exception chưa bắt | Thêm Express error middleware `(err, req, res, next)` |
| `src/server.js` | Thiếu graceful shutdown khi nhận SIGTERM/SIGINT | Thêm `server.close()` với timeout 5 giây |
| `src/services/transfer.js` | Không có cách xóa logs server-side → logs hiện lại sau reload dù đã "Dọn log" | Thêm hàm `clearLogs()` |
| `src/routes/api.js` | Thiếu endpoint xóa logs job | Thêm `POST /api/jobs/logs/clear` |
| `public/js/api.js` | Thiếu `clearJobLogs()` | Thêm method `clearJobLogs` gọi `/api/jobs/logs/clear` |

### ✨ Cải tiến

- **package.json**: Nâng version lên `2.1.0`; thêm script `test` chạy `api-smoke.mjs`
- **server.js**: `HOST` có thể cấu hình qua biến môi trường `HOST`
- **Monitor**: Hiệu năng tốt hơn — dừng poll ngay khi idle, tự khởi động lại khi phát hiện job đang chạy

---

## [2.0.1] — 2026-11-23 (Bugfix patch)

### 🐛 Sửa lỗi

| File | Lỗi | Fix |
|------|-----|-----|
| `package.json` | Version hardcode `1.4.0` nhưng code đã là v2.0.0 | Nâng lên `2.0.0` |
| `src/server.js` | Hardcode `v1.4.0` trong log khởi động | Đọc từ `package.json` qua `pkg.version` |
| `src/routes/api.js` | Hardcode `'1.4.0'` trong `/api/health` | Đọc từ `package.json` qua `pkg.version` |
| `public/js/monitor.js` | Toggle ▼/▲ bị ngược: click "Thu gọn" thì mở rộng và ngược lại | Đảo logic `isVisible` thay vì `isHidden` |
| `src/services/transfer.js` | `finish()` không lưu `deviceSerial` và `note` vào history → lịch sử hiện serial `—` | Thêm `deviceSerial` và `note` vào history entry |
| `src/services/transfer.js` | `begin()` không nhận `options` → `note` và `deviceSerial` không được lưu khi job bắt đầu | Mở rộng signature `begin(type, total, options)` |
| `src/services/transfer.js` | `restoreOne()` khi archive extract không có prefix folder: `source = temp` rồi push cả temp vào device → thiếu thư mục `com.zing.zalo` | Tạo `_remap/com.zing.zalo/` chuẩn trước khi push |
| `src/services/adb.js` | `getDeviceInfo` dùng `echo "MANUF=$(getprop ... || getprop ...)"` — `||` trong subshell `$()` không portable trên Android sh | Dùng `printf "MANUF=%s\n" "$(getprop ...)"` riêng từng lệnh |
| `src/services/archive.js` | `zipFolder()` khi native zip nhưng `sourceFolder` tên khác `internalDirName` → bỏ native zip luôn, dùng AdmZip (chậm) | Rename folder tạm vào wrapper dir, zip đúng tên, rename lại |

---

## [2.0.0] — 2026-11-23

### 🏗 Kiến trúc (Architecture)
- **Modular Architecture**: Tách toàn bộ HTML, CSS, JS thành các file riêng biệt, mỗi file chỉ chịu một trách nhiệm.
- **SPA + Hash Routing**: Điều hướng qua hash (`#overview`, `#devices`, ...) không reload trang.
- **Dynamic Component Loading**: `ui-loader.js` tải layout, header, sidebar động qua fetch và inject vào DOM.
- **Event-driven**: Router phát `view:activated`, job monitor phát `job:finished` để các view controller tự làm mới.

### 📁 Cấu trúc thư mục mới
```
public/
  components/
    header.html       — Thanh header (logo, theme toggle, settings)
    sidebar.html      — Menu điều hướng desktop
  css/
    variables.css     — Design tokens (colors, spacing, breakpoints)
    base.css          — Reset & typography
    layout.css        — App shell, sidebar, header, content-wrapper
    components.css    — Card, button, pill, form, modal, toast, monitor
    views.css         — Style riêng từng view
    responsive.css    — Media queries (mobile/tablet/desktop/large)
  js/
    api.js            — API client layer (tất cả HTTP calls)
    ui.js             — UI utilities (toast, modal, format, escape)
    monitor.js        — Live job monitor widget
    router.js         — Hash router (view switching, title update)
    ui-loader.js      — Inject layout + components, init router
    app.js            — Bootstrapper (init view controllers)
    views/
      overview.js     — Trang Tổng quan & Dashboard stats
      devices.js      — Trang Quản lý thiết bị ADB
      backups.js      — Trang Tạo sao lưu
      restore.js      — Trang Khôi phục (NEW)
      explorer.js     — Trang Kho tệp & Lưu trữ
      history.js      — Trang Lịch sử (search, filter, bulk delete, log)
      settings.js     — Trang Cài đặt & Bác sĩ hệ thống
  layout.html         — SPA layout template (mọi pages)
  index.html          — Entry point (chỉ có #app-root + scripts)
  style.css           — Import entrypoint

src/
  routes/api.js       — Thêm history search, bulk delete, clearAll
  services/store.js   — Thêm deleteManyHistory()
test/
  api-smoke.mjs       — Smoke test cho tất cả API endpoints (NEW)
```

### ✨ Tính năng mới
- **Multi-page Responsive UI**: 7 trang, tương thích laptop/tablet/điện thoại.
- **Sidebar + Header + Mobile Bottom Nav**: Layout đa thiết bị, sidebar ẩn/hiện trên mobile.
- **Theme System**: 3 theme (Mặc định / Midnight / Cyberpunk), lưu localStorage.
- **History nâng cao**: Tìm kiếm, lọc theo loại, chọn nhiều để xóa, xem log chi tiết.
- **Bulk Delete History**: `DELETE /api/history?ids=id1,id2,...`
- **Clear All History**: `DELETE /api/history/all` (tách riêng khỏi bulk delete)
- **History Search & Filter**: `GET /api/history?type=backup&search=keyword`
- **Restore View**: Giao diện đầy đủ cho khôi phục (chọn backup, chọn thiết bị, xác nhận).
- **API Smoke Test**: `node test/api-smoke.mjs` kiểm tra 13 endpoint tự động.

### 🐛 Sửa lỗi
- Đã sửa URL `inputConnectIp` và `inputConnectPort` không tồn tại trong HTML cũ.
- Đã chuẩn hóa ID DOM (không còn xung đột giữa `monitor-widget-container` và `#toast-container`).
- Đã đảm bảo `ui:ready` event chỉ kích hoạt sau khi layout được inject xong.

### 🔧 Backend
| Endpoint | Thay đổi |
|----------|----------|
| `GET /api/history?type=&search=` | Thêm query filter |
| `DELETE /api/history?ids=` | Mới — bulk delete |
| `DELETE /api/history/all` | Mới — xóa toàn bộ (tách khỏi bulk delete) |
| `DELETE /api/history/:id` | Vẫn hoạt động — xóa 1 mục |

### 📦 Hướng dẫn chạy
```bash
# Cài đặt
npm install

# Khởi động server
node src/server.js
# → http://127.0.0.1:5178

# Kiểm tra cú pháp
npm run check

# Smoke test API (server phải đang chạy)
node test/api-smoke.mjs

# Đóng gói
zip -r Nexus-Zalo-v2.0.0.zip public src bin README.md package.json CHANGELOG.md
```

---

## [1.4.0] — Phiên bản trước
- SPA monolithic với index.html chứa toàn bộ HTML.
- CSS và JS được tách thành modules nhưng toàn bộ HTML trong 1 file.
