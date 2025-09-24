# xtimizer
Универсальный оптимизатор медиафайлов.

### Команды для установки
 - Быстрая установка (curl):
```
curl -fsSL https://raw.githubusercontent.com/nikonbite/xtimizer/main/install.sh | bash
```
 - Быстрая установка (wget):
```
# С помощью wget
wget -qO- https://raw.githubusercontent.com/nikonbite/xtimizer/main/install.sh | bash
```
 - Установка по этапам:
```
wget https://raw.githubusercontent.com/nikonbite/xtimizer/main/install.sh
chmod +x install.sh
./install.sh
```
 - Ручная установка:
```
wget -O ~/.local/bin/xtimizer https://raw.githubusercontent.com/nikonbite/xtimizer/main/xtimizer
chmod +x ~/.local/bin/xtimizer
```

### Команды для удаления
 - Быстрое удаление (curl):
```
curl -fsSL https://raw.githubusercontent.com/nikonbite/xtimizer/main/uninstall.sh | bash
```
 - Быстрое удаление (wget):
```
# С помощью wget
wget -qO- https://raw.githubusercontent.com/nikonbite/xtimizer/main/uninstall.sh | bash
```
 - Удаление по этапам:
```
wget https://raw.githubusercontent.com/nikonbite/xtimizer/main/uninstall.sh
chmod +x uninstall.sh
./uninstall.sh
```

### Особенности
 - ✨ Красивая справка с примерами и списком поддерживаемых форматов
 - 🎯 Два режима: hls для видео, pictures для изображений
 - 📁 По умолчанию работает с текущей директорией
 - 🗑️ Безопасное удаление исходников только после успешной обработки
 - 📊 Подробная статистика и прогресс с эмодзи
 
### Примеры использования
 - xtimizer hls                       # Конвертировать все видео в текущей директории в HLS
 - xtimizer hls /path/to/videos       # Конвертировать видео из указанной директории  
 - xtimizer hls video.mp4 --delete    # Конвертировать один файл с удалением исходника
  
 - xtimizer pictures                  # Оптимизировать все изображения в текущей директории
 - xtimizer pictures /path/to/images  # Оптимизировать изображения из указанной директории
 - xtimizer pictures image.jpg -d     # Оптимизировать один файл с удалением исходника

Поддерживаемые форматы:
 - Видео: mp4, mkv, avi, mov, wmv, flv, webm, m4v, mpg, mpeg, 3gp
 - Изображения: jpg, jpeg, png, gif, bmp, tiff, tif, webp
  
made with ❤️ by @ikonbite
