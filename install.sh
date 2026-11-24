#!/usr/bin/env bash
# ==============================================================================
# Nexus-Zalo — Cross-platform Installation Script
# Hỗ trợ: Android (Termux), macOS, Linux
# ==============================================================================

set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

# Màu hiển thị
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

echo -e "${CYAN}${BOLD}"
echo "=========================================================="
echo "          NEXUS-ZALO — CÀI ĐẶT HỆ THỐNG                   "
echo "=========================================================="
echo -e "${NC}"

# ── 1. NHẬN DIỆN MÔI TRƯỜNG HỆ ĐIỀU HÀNH ──────────────────────
IS_TERMUX=false
IS_MACOS=false
IS_LINUX=false

if [ -n "$TERMUX_VERSION" ] || [ -d "/data/data/com.termux" ] || [ -f "/data/data/com.termux/files/usr/bin/pkg" ]; then
  IS_TERMUX=true
  OS_NAME="Android (Termux)"
elif [[ "$OSTYPE" == "darwin"* ]]; then
  IS_MACOS=true
  OS_NAME="macOS"
else
  IS_LINUX=true
  OS_NAME="Linux"
fi

echo -e "📌 Môi trường phát hiện: ${BOLD}${OS_NAME}${NC}\n"

# ── 2. XỬ LÝ THEO TỪNG MÔI TRƯỜNG ────────────────────────────

if [ "$IS_TERMUX" = true ]; then
  echo -e "${CYAN}🤖 Đang chạy trên Termux: Tự động cài đặt các gói cần thiết...${NC}"
  
  # Danh sách gói Termux cần thiết
  TERMUX_PACKAGES="nodejs-lts android-tools zip unzip tar git curl"
  
  echo -e "   Đang kiểm tra và cài đặt: ${TERMUX_PACKAGES}..."
  pkg update -y || apt update -y
  pkg install -y $TERMUX_PACKAGES || apt install -y $TERMUX_PACKAGES
  
  echo -e "${GREEN}✅ Đã cài đặt xong các gói Termux!${NC}\n"

elif [ "$IS_MACOS" = true ]; then
  echo -e "${CYAN}🍏 Đang chạy trên macOS: Kiểm tra các công cụ hệ thống...${NC}"
  MISSING_REQUIRED=false

  # Kiểm tra Node.js
  if ! command -v node >/dev/null 2>&1; then
    echo -e "${RED}❌ LỖI: Node.js chưa được cài đặt!${NC}"
    echo -e "   👉 Vui lòng cài đặt Node.js (phiên bản 20+):"
    echo -e "      - Dùng Homebrew: ${BOLD}brew install node${NC}"
    echo -e "      - Hoặc tải trực tiếp tại: ${CYAN}https://nodejs.org${NC}"
    MISSING_REQUIRED=true
  else
    NODE_VER=$(node -v)
    echo -e "   ✅ Node.js: ${NODE_VER}"
  fi

  # Kiểm tra ADB
  if ! command -v adb >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  CẢNH BÁO: ADB (Android Debug Bridge) chưa có trong PATH!${NC}"
    echo -e "   👉 Nexus-Zalo cần ADB để kết nối thiết bị Android. Vui lòng cài đặt:"
    echo -e "      - Dùng Homebrew: ${BOLD}brew install --cask android-platform-tools${NC}"
    echo -e "      - Hoặc tải tại: ${CYAN}https://developer.android.com/tools/releases/platform-tools${NC}"
  else
    echo -e "   ✅ ADB: $(adb version 2>/dev/null | head -n1 || echo 'Sẵn sàng')"
  fi

  # Kiểm tra tiện ích zip/tar
  for tool in zip unzip tar; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      echo -e "${YELLOW}⚠️  Thiếu '$tool' (khuyến nghị cài qua: brew install $tool)${NC}"
    fi
  done

  if [ "$MISSING_REQUIRED" = true ]; then
    echo -e "\n${RED}⛔ Vui lòng cài đặt Node.js rồi chạy lại script này.${NC}"
    exit 1
  fi
  echo ""

else
  # Linux Desktop / Server
  echo -e "${CYAN}🐧 Đang chạy trên Linux: Kiểm tra các công cụ hệ thống...${NC}"
  MISSING_REQUIRED=false

  # Kiểm tra Node.js
  if ! command -v node >/dev/null 2>&1; then
    echo -e "${RED}❌ LỖI: Node.js chưa được cài đặt!${NC}"
    echo -e "   👉 Vui lòng cài đặt Node.js (LTS 20+):"
    echo -e "      - Ubuntu/Debian: ${BOLD}sudo apt update && sudo apt install -y nodejs npm${NC}"
    echo -e "      - Fedora:        ${BOLD}sudo dnf install -y nodejs npm${NC}"
    echo -e "      - Arch Linux:    ${BOLD}sudo pacman -S nodejs npm${NC}"
    echo -e "      - Hoặc qua nvm:  ${CYAN}https://github.com/nvm-sh/nvm${NC}"
    MISSING_REQUIRED=true
  else
    echo -e "   ✅ Node.js: $(node -v)"
  fi

  # Kiểm tra ADB
  if ! command -v adb >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  CẢNH BÁO: ADB chưa được cài đặt!${NC}"
    echo -e "   👉 Để kết nối điện thoại Android, hãy cài đặt android-tools:"
    echo -e "      - Ubuntu/Debian: ${BOLD}sudo apt install -y adb${NC}"
    echo -e "      - Fedora:        ${BOLD}sudo dnf install -y android-tools${NC}"
    echo -e "      - Arch Linux:    ${BOLD}sudo pacman -S android-tools${NC}"
  else
    echo -e "   ✅ ADB: $(adb version 2>/dev/null | head -n1 || echo 'Sẵn sàng')"
  fi

  # Kiểm tra zip/unzip/tar
  for tool in zip unzip tar; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      echo -e "${YELLOW}⚠️  Thiếu '$tool' (hỗ trợ nén/giải nén nhanh). Cài: sudo apt install -y $tool${NC}"
    fi
  done

  if [ "$MISSING_REQUIRED" = true ]; then
    echo -e "\n${RED}⛔ Vui lòng cài đặt Node.js rồi chạy lại script này.${NC}"
    exit 1
  fi
  echo ""
fi

# ── 3. CHUẨN BỊ MÔI TRƯỜNG & BIẾN CẤU HÌNH (.env) ────────────
if [ ! -f .env ] && [ -f .env.example ]; then
  echo -e "${CYAN}📄 Khởi tạo file cấu hình .env từ .env.example...${NC}"
  cp .env.example .env
  echo -e "${GREEN}✅ Đã tạo file .env (Bạn có thể điền SEPAY_API_KEY khi cần).${NC}\n"
fi

# ── 4. SỬA SHEBANG CHO TERMUX NẾU CÓ ─────────────────────────
if command -v termux-fix-shebang >/dev/null 2>&1; then
  echo -e "🔧 Tối ưu hóa shebang cho Termux..."
  termux-fix-shebang bin/nexus-zalo.js || true
fi

# ── 5. CÀI ĐẶT DEPENDENCIES & CLI LINK ────────────────────────
echo -e "${CYAN}📦 Đang cài đặt thư viện Node.js (npm install)...${NC}"
npm install

echo -e "\n${CYAN}🔗 Đăng ký lệnh toàn cục 'nexus-zalo' (npm link)...${NC}"
npm link || {
  echo -e "${YELLOW}⚠️  'npm link' cần quyền root/admin hoặc thiết lập prefix. Bạn vẫn có thể chạy qua: npm start${NC}"
}

# ── 6. HOÀN TẤT ──────────────────────────────────────────────
echo -e "\n${GREEN}${BOLD}=========================================================="
echo "🎉 CÀI ĐẶT NEXUS-ZALO THÀNH CÔNG!"
echo "==========================================================${NC}"
echo -e "Khởi động ứng dụng bằng một trong các cách sau:"
echo -e "  1. Lệnh toàn cục:  ${CYAN}${BOLD}nexus-zalo${NC}"
echo -e "  2. Hoặc chạy trực tiếp: ${CYAN}${BOLD}npm start${NC}"
echo -e "\nDashboard sẽ mở tại: ${BOLD}http://127.0.0.1:5178${NC}\n"
