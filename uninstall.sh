#!/bin/bash

# XTimizer Uninstaller
# Удаление XTimizer из Linux систем

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

# Функция удаления PATH из конфигов
remove_from_configs() {
    local configs=(
        "$HOME/.bashrc"
        "$HOME/.bash_profile" 
        "$HOME/.zshrc"
        "$HOME/.profile"
    )
    
    print_info "Удаляем записи PATH из конфигурационных файлов..."
    
    for config in "${configs[@]}"; do
        if [ -f "$config" ]; then
            # Создаем временный файл без строк xtimizer
            if grep -q "xtimizer" "$config" 2>/dev/null; then
                print_info "Очищаем $config..."
                
                # Удаляем строки содержащие xtimizer или наш INSTALL_DIR
                sed -i.bak '/# Added by xtimizer installer/d' "$config" 2>/dev/null || true
                sed -i.bak "\|$INSTALL_DIR|d" "$config" 2>/dev/null || true
                
                # Удаляем backup файлы
                rm -f "$config.bak" 2>/dev/null || true
                
                print_success "Очищен $config"
            fi
        fi
    done
    
    # Для fish отдельная обработка
    if command -v fish >/dev/null 2>&1; then
        print_info "Удаляем PATH из fish конфигурации..."
        fish -c "set -e fish_user_paths[$INSTALL_DIR]" 2>/dev/null || true
        fish -c "set -U fish_user_paths (string match -v $INSTALL_DIR \$fish_user_paths)" 2>/dev/null || true
        print_success "PATH удален из fish"
    fi
}

# Функция удаления скрипта
remove_script() {
    local script_path="$INSTALL_DIR/$SCRIPT_NAME"
    
    if [ -f "$script_path" ]; then
        print_info "Удаляем скрипт $script_path..."
        rm -f "$script_path"
        print_success "Скрипт удален"
    else
        print_warning "Скрипт $script_path не найден"
    fi
}

# Функция очистки пустых директорий
cleanup_dirs() {
    # Проверяем, пуста ли директория установки
    if [ -d "$INSTALL_DIR" ]; then
        if [ -z "$(ls -A "$INSTALL_DIR" 2>/dev/null)" ]; then
            print_info "Удаляем пустую директорию $INSTALL_DIR..."
            rmdir "$INSTALL_DIR" 2>/dev/null || true
        else
            print_info "Директория $INSTALL_DIR не пуста, оставляем её"
        fi
    fi
}

# Основная функция удаления
main() {
    echo -e "${RED}"
    cat << "EOF"
 __  _______  _                    _ 
 \ \/ /_   _|(_) _ __ ___    ___  | |
  \  /  | |  | || '_ ` _ \  / _ \ | |
  /  \  | |  | || | | | | ||  __/ |_|
 /_/\_\ |_|  |_||_| |_| |_| \___| (_)
                                     
      Деинсталляция XTimizer
EOF
    echo -e "${NC}"
    
    # Подтверждение удаления
    print_warning "Вы собираетесь удалить XTimizer из системы"
    read -p "Продолжить удаление? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Удаление отменено"
        exit 0
    fi
    
    print_info "Начинаем удаление XTimizer..."
    
    # Удаляем скрипт
    remove_script
    
    # Очищаем конфигурационные файлы
    remove_from_configs
    
    # Очищаем пустые директории
    cleanup_dirs
    
    print_success "✅ XTimizer успешно удален!"
    echo
    print_info "Рекомендуется перезапустить терминал для применения изменений"
    print_warning "ffmpeg остался в системе (если был установлен автоматически)"
    
    echo
    print_info "Если хотите переустановить XTimizer:"
    echo -e "${GREEN}curl -fsSL https://raw.githubusercontent.com/nikonbite/xtimizer/main/install.sh | bash${NC}"
    echo
    print_info "Репозиторий: https://github.com/nikonbite/xtimizer"
}

# Проверка что скрипт установлен
check_installation() {
    if [ ! -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
        print_warning "XTimizer не найден в $INSTALL_DIR/$SCRIPT_NAME"
        print_info "Возможно он уже удален или установлен в другом месте"
        
        read -p "Продолжить очистку конфигураций? (y/N): " -n 1 -r
        echo
        
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi
}

# Запуск
check_installation
main "$@"
