#!/bin/bash
echo "Скрипт запущен!"
history -r
apt update -y
echo ""
echo "Запущена проверка установленных зависимостей"

packages=("python" "python3" "python3-pip" "git" "wget" "curl" "nano" "tput")

for package in "${packages[@]}"
do
    if ! dpkg -s "$package" >/dev/null 2>&1; then
        echo "Идет установка $package"
         apt-get -qq install $package > >(stdbuf -o0 sed 's/^/ /') 2>&1 | stdbuf -o0 awk '/Progress:/ {print $2, $3}'
    fi
done

echo -e "\033[32 Установка всех зависимостей завершена\nЗапущен процесс настройки"

if [ ! -d "$HOME/BSSERVERS" ]; then
    mkdir $HOME/BSSERVERS
    echo > $HOME/BSSERVERS/data
fi
echo "Classic_BrawlV2, https://github.com/PhoenixFire6934/Classic-Brawl.git"> ~/BSSERVERS/data
echo "OldBrawl, https://github.com/VitalikObject/OldBrawl.git" >> ~/BSSERVERS/data
echo "ModerBrawlV2, https://github.com/PhoenixFire6934/Modern-Brawl.git" >> ~/BSSERVERS/data
echo "BrawlStrars-Server(требуется_dotnet), https://github.com/VitalikObject/BrawlStars-Server.git" >> ~/BSSERVERS/data

echo -e "\e[92mНастройка завершена!\e[0m"
sleep 2
clear
versions=$(cat ~/BSSERVERS/data | awk -F, '{gsub(/^[ \t]+|[ \t]+$/, "", $1);print $1}' | tr '\n' ' ')

echo -e "\e[1;31mАвтор -> github.com/middle1\e[0m" | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
echo -e "\nПоддерживаемые версии на данный момент:"

i=1
for version in $versions
do
  # получаем имя серверов из файла
  name=$(sed -n "$i"p ~/BSSERVERS/data | cut -d',' -f1)
  # получаем ссылку из файла
  url=$(cat ~/BSSERVERS/data | awk -F, '{if(NR=='$i') print $2}' | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
  # проверяем, установлен ли сервер
  installed=$(ls ~/BSSERVERS | grep "$name")

  if [ -n "$installed" ]; then
    echo -e "${i}. \e[92m[+]\e[0m \e[32m$name\e[0m\n"
  else
    echo -e "${i}. \e[31m[-]\e[0m \e[31m$name\e[0m\n"
  fi

  i=$((i+1))
done

PS1="------> "

while true; do
  read -e -i "$input" -p "-------------> " input
  history -s "$input"

  if [[ "$input" == *"input"* ]]; then
    echo "input found: $input"
  elif [[ "$input" == "exit" || "$input" == "stop" ]]; then
    echo "By MIDDLE1221"
    exit 0
  elif [[ "$input" =~ ^[1-9][0-9]*$ ]]; then
    # получаем имя сервера из файла
    name=$(cat ~/BSSERVERS/data | awk -F, '{if(NR=='$input') print $1}')
    # получаем ссылку из файла
    url=$(cat ~/BSSERVERS/data | awk -F, '{if(NR=='$input') print $2}' | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
    # проверяем, что ссылка не пустая
    if [ -n "$url" ]; then
      echo "Скачиваем репозиторий с сервером $name ..."
      cd ~/BSSERVERS
      # проверяем, что директории сервера ещё нет
      if [ -d "$name" ]; then
        echo "Сервер $name уже установлен"
        continue
      fi
      # создаём директорию, если её нет
      mkdir -p "$name"
      cd "$name"
      # клонируем репозиторий по ссылке
      git clone "$url" .
      echo "Сервер $name успешно скачан и сохранён в папке ~/BSSERVERS!"
    else
      echo "Ошибка: не найдена ссылка для выбранного сервера"
    fi
  else
    echo "Комманда не распознана. Для выхода напишите stop или exit"
  fi
done