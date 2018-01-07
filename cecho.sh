#!/bin/bash

# NOTA
# Il carattere di escape e` dato dalle lettere "\e", ed il comando echo (come si puo` notare) e` seguito dall' opzione "-e".

# Help
if [[ $# -ne 2 || $1 = "-h" ]]; then
    echo ""
    echo -e "\e[1mUso: $0 \"format_code[;format_code][;format_code]..\" \"text to display\"\e[0m"
    echo
    echo "** The formatting codes are as follows **"
    echo
    echo "0 reset all attributes"
    echo -e "1 \e[1mbold\e[0m"
    echo -e "2 \e[2mhalf-bright\e[0m"
    echo -e "4 \e[4munderscore\e[0m"
    echo -e "5 \e[5mblink\e[0m"
    echo -e "7 \e[7mreverse colours\e[0m"
    echo
    echo "*** The colour codes are as follows ***"
    echo
    echo "** Foreground colours **"
    echo -e "30 \e[30mblack\e[0m"
    echo -e "31 \e[31mred\e[0m"
    echo -e "32 \e[32mgreen\e[0m"
    echo -e "33 \e[33mbrown\e[0m"
    echo -e "34 \e[34mblue\e[0m"
    echo -e "35 \e[35mmagenta\e[0m"
    echo -e "36 \e[36mcyan\e[0m"
    echo -e "37 \e[37mwhite \e[0m"
    echo
    echo "** Background colours **"
    echo -e "40 \e[40mblack\e[0m"
    echo -e "41 \e[41mred\e[0m"
    echo -e "42 \e[42mgreen\e[0m"
    echo -e "43 \e[43mbrown\e[0m"
    echo -e "44 \e[44mblue\e[0m"
    echo -e "45 \e[45mmagenta\e[0m"
    echo -e "46 \e[46mcyan\e[0m"
    echo -e "47 \e[47mwhite\e[0m"
    echo
    echo
    echo -e "\e[4mEsempi d'utilizzo:\e[0m"
    echo
    echo "$0 \"1\" \"esempio 1\""
    echo -e "\e[1mesempio 1\e[0m"
    echo
    echo "$0 \"32\" \"esempio 2\""
    echo -e "\e[32mesempio 2\e[0m"
    echo
    echo "$0 \"5;34;46\" \"esempio 3\""
    echo -e "\e[5;34;46mesempio 3\e[0m"
    echo
    echo "$0 \"1;4;5\" \"esempio 4\""
    echo -e "\e[1;4;5mesempio 4\e[0m"
    echo
    exit 1
fi

echo -ne "\e[${1}m${2}\e[0m"
