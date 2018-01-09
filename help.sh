#!/bin/bash

#               1234567890123456|234567890123456|234567890123456|
cecho.sh "31"  "Help:"
sleep 1
#               1234567890123456|234567890123456|234567890123456|
cecho.sh "1" "\nq"
cecho.sh "0"    " ferma il pro- gramma e ritornain console tty."
sleep 3
#               1234567890123456|234567890123456|234567890123456|
cecho.sh "1" "\ne"
cecho.sh "0"    " per modificareil programma."
sleep 3
#               1234567890123456|234567890123456|234567890123456|
cecho.sh "1" "\nv"
cecho.sh "0"    " visualizza    programmazione  odierna."
sleep 3
#               1234567890123456|234567890123456|234567890123456|
cecho.sh "1" "\nm"
cecho.sh "0"    " modifica la   configurazione."
sleep 3

#               1234567890123456|234567890123456|234567890123456|
# Per qualche strano motivo, non funzionano tutti i i codici e la linea successiva non lampeggia ..
cecho.sh "5" "\nReload program.."
#echo -e "\e[5m\nReload program..\e[0m"
sleep 1
