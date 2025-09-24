#!/bin/bash

# XTimizer Installer
# Автоматическая установка XTimizer на Linux системы

set -e

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Переменные
INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="xtimizer"
REPO_URL="https://raw.githubusercontent.com/nikonbite/xtimizer/main/xtimizer"

# Функция для вывода с цветами
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Функция определения дистрибутива
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    elif [ -f /etc/redhat-release ]; then
        OS="centos"
    elif [ -f /etc/debian_version ]; then
        OS="debian"
    else
        OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    fi
    echo $OS
}

# Функция установки ffmpeg
install_ffmpeg() {
    local os=$(detect_os)
    
    print_info "Устанавливаем ffmpeg для $os..."
    
    case $os in
        ubuntu|debian|pop|mint|elementary)
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update
                sudo apt-get install -y ffmpeg
            elif command -v apt >/dev/null 2>&1; then
                sudo apt update
                sudo apt install -y ffmpeg
            else
                print_error "Не удалось найти менеджер пакетов apt"
                return 1
            fi
            ;;
        fedora|centos|rhel|rocky|almalinux)
            if command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y ffmpeg
            elif command -v yum >/dev/null 2>&1; then
                # Для CentOS/RHEL может потребоваться EPEL
                if ! rpm -qa | grep -q epel-release; then
                    sudo yum install -y epel-release
                fi
                sudo yum install -y ffmpeg
            else
                print_error "Не удалось найти менеджер пакетов dnf/yum"
                return 1
            fi
            ;;
        opensuse*|sles)
            if command -v zypper >/dev/null 2>&1; then
                sudo zypper install -y ffmpeg
            else
                print_error "Не удалось найти менеджер пакетов zypper"
                return 1
            fi
            ;;
        arch|manjaro|endeavouros|garuda)
            if command -v pacman >/dev/null 2>&1; then
                sudo pacman -S --noconfirm ffmpeg
            elif command -v yay >/dev/null 2>&1; then
                yay -S --noconfirm ffmpeg
            else
                print_error "Не удалось найти менеджер пакетов pacman/yay"
                return 1
            fi
            ;;
        alpine)
            if command -v apk >/dev/null 2>&1; then
                sudo apk add ffmpeg
            else
                print_error "Не удалось найти менеджер пакетов apk"
                return 1
            fi
            ;;
        void)
            if command -v xbps-install >/dev/null 2>&1; then
                sudo xbps-install -y ffmpeg
            else
                print_error "Не удалось найти менеджер пакетов xbps-install"
                return 1
            fi
            ;;
        *)
            print_warning "Неизвестный дистрибутив: $os"
            print_info "Попробуйте установить ffmpeg вручную:"
            print_info "- Ubuntu/Debian: sudo apt install ffmpeg"
            print_info "- Fedora: sudo dnf install ffmpeg"
            print_info "- Arch: sudo pacman -S ffmpeg"
            print_info "- openSUSE: sudo zypper install ffmpeg"
            return 1
            ;;
    esac
}

# Функция проверки ffmpeg
check_ffmpeg() {
    if command -v ffmpeg >/dev/null 2>&1; then
        print_success "ffmpeg уже установлен"
        return 0
    else
        print_warning "ffmpeg не найден"
        read -p "Установить ffmpeg автоматически? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            install_ffmpeg
            if command -v ffmpeg >/dev/null 2>&1; then
                print_success "ffmpeg успешно установлен"
                return 0
            else
                print_error "Не удалось установить ffmpeg"
                return 1
            fi
        else
            print_warning "ffmpeg не будет установлен. Установите его вручную перед использованием xtimizer"
            return 0
        fi
    fi
}

# Функция добавления PATH в shell конфиги
add_to_path() {
    local shell_config=""
    local current_shell=$(basename "$SHELL")
    
    # Определяем файл конфигурации для текущей оболочки
    case $current_shell in
        bash)
            if [ -f "$HOME/.bashrc" ]; then
                shell_config="$HOME/.bashrc"
            elif [ -f "$HOME/.bash_profile" ]; then
                shell_config="$HOME/.bash_profile"
            fi
            ;;
        zsh)
            if [ -f "$HOME/.zshrc" ]; then
                shell_config="$HOME/.zshrc"
            fi
            ;;
        fish)
            # Fish хранит PATH по-другому
            if command -v fish >/dev/null 2>&1; then
                fish -c "set -U fish_user_paths $INSTALL_DIR \$fish_user_paths" 2>/dev/null || true
                print_success "PATH добавлен в fish конфигурацию"
            fi
            return 0
            ;;
    esac
    
    # Добавляем PATH в конфиг если он найден
    if [ -n "$shell_config" ] && [ -f "$shell_config" ]; then
        if ! grep -q "$INSTALL_DIR" "$shell_config" 2>/dev/null; then
            echo "" >> "$shell_config"
            echo "# Added by xtimizer installer" >> "$shell_config"
            echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$shell_config"
            print_success "PATH добавлен в $shell_config"
        else
            print_info "PATH уже настроен в $shell_config"
        fi
    fi
    
    # Также добавляем в общие конфиги для совместимости
    for config in "$HOME/.profile" "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$config" ] && [ "$config" != "$shell_config" ]; then
            if ! grep -q "$INSTALL_DIR" "$config" 2>/dev/null; then
                echo "" >> "$config"
                echo "# Added by xtimizer installer" >> "$config" 
                echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$config"
                print_info "PATH добавлен в $config"
            fi
        fi
    done
}

# Основная функция установки
main() {
    echo -e "${BLUE}"
    cat << "EOF"
▗▖  ▗▖  ■  ▄ ▄▄▄▄  ▄ ▄▄▄▄▄ ▗▞▀▚▖ ▄▄▄ 
 ▝▚▞▘▗▄▟▙▄▖▄ █ █ █ ▄  ▄▄▄▀ ▐▛▀▀▘█    
  ▐▌   ▐▌  █ █   █ █ █▄▄▄▄ ▝▚▄▄▖█    
▗▞▘▝▚▖ ▐▌  █       █                 
       ▐▌                            
                                     
    Универсальный оптимизатор медиафайлов
EOF
    echo -e "${NC}"
    
    print_info "Начинаем установку XTimizer..."
    
    # Создаем директорию для установки
    print_info "Создаем директорию $INSTALL_DIR..."
    mkdir -p "$INSTALL_DIR"
    
    # Проверяем ffmpeg
    check_ffmpeg
    
    # Скачиваем скрипт
    print_info "Скачиваем xtimizer из репозитория..."
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$REPO_URL" -o "$INSTALL_DIR/$SCRIPT_NAME"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$REPO_URL" -O "$INSTALL_DIR/$SCRIPT_NAME"
    else
        print_error "Не найден curl или wget для скачивания файлов"
        exit 1
    fi
    
    # Делаем исполняемым
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    print_success "Скрипт установлен в $INSTALL_DIR/$SCRIPT_NAME"
    
    # Настраиваем PATH
    print_info "Настраиваем PATH для различных оболочек..."
    add_to_path
    
    # Проверяем установку
    if [ -x "$INSTALL_DIR/$SCRIPT_NAME" ]; then
        print_success "✅ XTimizer успешно установлен!"
        echo
        print_info "Перезапустите терминал или выполните:"
        echo -e "${YELLOW}source ~/.bashrc${NC} (для bash)"
        echo -e "${YELLOW}source ~/.zshrc${NC} (для zsh)"  
        echo -e "${YELLOW}Для fish просто откройте новый терминал${NC}"
        echo
        print_info "Затем используйте команды:"
        echo -e "${GREEN}xtimizer${NC}                    # Показать справку"
        echo -e "${GREEN}xtimizer hls${NC}                # Конвертировать видео в HLS"
        echo -e "${GREEN}xtimizer pictures${NC}           # Оптимизировать изображения"
        echo
        print_info "Репозиторий: https://github.com/nikonbite/xtimizer"
    else
        print_error "Что-то пошло не так при установке"
        exit 1
    fi
}

# Запуск
main "$@"
