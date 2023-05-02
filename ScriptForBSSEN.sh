#!/bin/bash
echo "Script started!"
history -r
apt update -y
echo ""
echo "Checking installed dependencies"

packages=("python" "python3" "python3-pip" "git" "wget" "curl" "nano" "tput")

for package in "${packages[@]}"
do
    if ! dpkg -s "$package" >/dev/null 2>&1; then
        echo "Installing $package"
         apt-get -qq install $package > >(stdbuf -o0 sed 's/^/ /') 2>&1 | stdbuf -o0 awk '/Progress:/ {print $2, $3}'
    fi
done

print_center(){
    local x
    local y
    text="$*"
    x=$(( ($(tput cols) - ${#text}) / 2))
    echo -ne "\E[6n";read -sdR y; y=$(echo -ne "${y#*[}" | cut -d';' -f1)
    echo -ne "\033[${y};${x}f$*"
}

echo -e "\033[32mInstallation of all dependencies is done.\nStarting setup process.\033[0m"

if [ ! -d "$HOME/BSSERVERS" ]; then
    mkdir $HOME/BSSERVERS
    echo > $HOME/BSSERVERS/data
fi

echo "Classic_BrawlV2, https://github.com/PhoenixFire6934/Classic-Brawl.git"> ~/BSSERVERS/data
echo "OldBrawl, https://github.com/VitalikObject/OldBrawl.git" >> ~/BSSERVERS/data
echo "ModerBrawlV2, https://github.com/PhoenixFire6934/Modern-Brawl.git" >> ~/BSSERVERS/data
echo "BrawlStrars-Server(requires_dotnet), https://github.com/VitalikObject/BrawlStars-Server.git" >> ~/BSSERVERS/data

echo -e "\e[92mSetup complete!\e[0m"
sleep 2
clear

versions=$(cat ~/BSSERVERS/data | awk -F, '{gsub(/^[ \t]+|[ \t]+$/, "", $1);print $1}' | tr '\n' ' ')

space=$(printf '%*s' "$((($COLUMNS-108)))")
echo -e '\e[1;31mAuthor -> github.com/middle1\e[0m' | sed  -e :a -e "s/^.\{1,$(tput cols)\}$/ & /;ta" | tr -d '\n' | head -c $(tput cols)
echo  -e "\nCurrently supported versions:"

i=1
for version in $versions
do
  name=$(sed -n "$i"p ~/BSSERVERS/data | cut -d',' -f1)
  url=$(cat ~/BSSERVERS/data | awk -F, '{if(NR=='$i') print $2}' | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
  installed=$(ls ~/BSSERVERS | grep "$name")

  if [ -n "$installed" ]; then
    echo -e "${i}. \e[92m[+]\e[0m \e[32m$name\e[0m"
    echo ""
  else
    echo -e "${i}. \e[31m[-]\e[0m \e[31m$name\e[0m"
    echo ""
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
    name=$(cat ~/BSSERVERS/data | awk -F, '{if(NR=='$input') print $1}')
    url=$(cat ~/BSSERVERS/data | awk -F, '{if(NR=='$input') print $2}' | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
    if [ -n "$url" ]; then
      echo "Downloading repository for server $name ..."
      cd ~/BSSERVERS
      if [ -d "$name" ]; then
        echo "Server $name is already installed"
        continue
      fi
      mkdir -p "$name"
      cd "$name"
      git clone "$url" .
      echo "Server $name successfully downloaded and saved in ~/BSSERVERS directory!"
    else
      echo "Error: No link found for selected server"
    fi
  else
    echo "Command not recognized. Type stop or exit to exit."
  fi
done
