# 📋 CẤU TRÚC FILE - LOVE STATION

## 📁 Thư mục chính

### `lib/main.dart` - File chính của app
- **SplashScreen**: Màn hình khởi động với animation
- **LovePage**: Màn hình chính với đầy đủ tính năng
- **AI LuLu**: Trợ lý thông minh (dùng icon `lulu_icon.png`)
- **Music Player**: Phát nhạc từ `assets/music/`
- **Chat realtime**: Nhắn tin qua Firebase
- **Calendar**: Lịch sự kiện
- **Todo List**: Việc需要 làm
- **Water Reminder**: Nhắc uống nước

### `assets/` - Thư mục chứa tài nguyên
- `gau_bong.png` - Avatar Gấu bông
- `be_trang.png` - Avatar Bé Trắng
- `lulu_icon.png` - Icon AI LuLu (mới thêm)
- `background.png` - Hình nền
- `music/` - Thư mục nhạc
  - `song1.mp3` đến `song6.mp3` - Các bài hát
  - `notification.mp3` - Âm thanh thông báo
  - Các file âm thanh khác

### `pubspec.yaml` - Cấu hình project
- Dependencies: Firebase, audioplayers, confetti, shared_preferences...
- Assets declarations
- Fonts (NotoSans)

### `web/index.html` - File HTML cho web
- Cấu hình viewport
- Meta tags
- JavaScript cho web

## 🔧 Các tính năng chính

### 1. **Giao diện chính**
- Avatar Gấu & Bé với online status
- Bộ đếm ngày yêu nhau (từ 12/10/2025)
- Chat box realtime
- Action grid (Nhớ, Hôn, Ôm, Yêu thương...)
- Quick flirt buttons
- Input row với các icon chức năng

### 2. **AI LuLu** (Trợ lý thông minh)
- Patterns: yêu, nhớ, buồn, giận, ăn, uống, game...
- Gợi ý món ăn, đồ uống
- Gợi ý nhạc khi buồn/nhớ
- Quick question chips

### 3. **Music Player**
- Floating player ở bottom right
- Controls: play/pause, next/prev, repeat
- Playlist từ `assets/music/`
- ⚠️ **Lỗi web**: Một số file mp3 không phát được trên web

### 4. **Tính năng cảm xúc** (Cần tối ưu)
- Nhớ nhau (Gấu nhớ Bé, Bé nhớ Gấu)
- Các action: hôn, ôm, yêu thương...
- Bubble animation khi gửi action

### 5. **Calendar & Reminder**
- Thêm sự kiện với ngày/giờ
- Lời nhắc uống nước (chỉnh giờ được)
- Todo list cá nhân

### 6. **Game Cặp Đôi**
- Mini game "Ai hiểu ai hơn"
- Câu hỏi về kỷ niệm, sở thích...
- Hệ thống điểm số

## ⚠️ **Lỗi cần sửa**

### 1. **Nhạc không phát được trên web**
- **Hiện trạng**: Một số file mp3 bị lỗi "Format error (Code: 4)"
- **Nguyên nhân**: Trình duyệt không hỗ trợ format mp3 đó
- **Giải pháp**:
  - Convert sang format web-friendly (AAC, OGG)
  - Hoặc chỉ phát được trên mobile
  - Hoặc dùng audio codec khác

### 2. **Nút điều khiển không nhập được**
- **Hiện trạng**: Khi mở music player, không nhập liệu được
- **Nguyên nhân**: Focus bị che bởi overlay
- **Giải pháp**:
  - Thu nhỏ music player
  - Hoặc di chuyển vị trí
  - Hoặc thêm chế độ collapse

### 3. **Animation khởi động**
- **Yêu cầu**: Thêm Gấu & Bé vào animation
- **Hiện tại**: Chỉ có trái tim xoay
- **Cần làm**: 
  - Thêm avatar Gấu & Bé bay vào
  - Hiệu ứng gặp nhau
  - Sync với splash screen

## 📝 **Note cho anh**

### **Tài nguyên miễn phí giới hạn**
- Firebase Realtime Database: 1GB storage, 10GB/tháng transfer
- Nên tối ưu:
  - Không lưu trữ file lớn
  - Xóa data cũ không cần thiết
  - Dùng caching local

### **Icon AI LuLu**
- File: `assets/lulu_icon.png`
- Kích thước gợi ý: 100x100px
- Format: PNG (trong suốt càng tốt)
- Đã được tích hợp vào dialog AI LuLu

### **Nhạc quan trọng**
- Hiện tại có 6 bài trong playlist
- Nếu cần thêm, đặt tên `song7.mp3`, `song8.mp3`...
- Lưu vào `assets/music/`
- ⚠️ Nhớ convert sang format web-friendly nếu muốn phát trên web

### **Tính năng gợi ý**
- Nếu muốn thêm gợi ý mới, nói em để em cập nhật AI patterns
- Có thể thêm: gợi ý quà, địa điểm hẹn hò, phim...

## 🚀 **Cách chạy app**

```bash
# Chạy trên Edge (web)
flutter run -d edge

# Chạy trên Chrome
flutter run -d chrome

# Build web
flutter build web

# Build APK
flutter build apk
```

## 📱 **Tối ưu cho**
- ✅ iPhone 15 Pro Max (Dynamic Island)
- ✅ iOS 18
- ✅ Android mới
- ✅ Desktop Web
- ✅ Tablet

---

**Liên hệ**: Nếu cần sửa gì thêm thì báo em nha! 💖