#!/bin/bash

# NOTA
# Il carattere di escape e` dato dalle lettere "\e", ed il comando echo (come si puo` notare) e` seguito dall' opzione "-e".

# Help
if [[ $# -ne 1 || $1 = "-h" ]]; then
    echo ""
    echo -e "\e[1mUso: $0 \"<parametri>\"\e[0m"
    echo
    echo "** Parametri utilizzabili **"
    echo
    echo -e "\e[1m<L>;<C>H\e[0m"
    echo -e "Posiziona il cursore alla linea <L>, colonna <C>"
    echo
    echo -e "\e[1m<L>A\e[0m"
    echo -e "Sposta il cursore verso l'alto di <L> linee"
    echo
    echo -e "\e[1m<L>B\e[0m"
    echo -e "Sposta il cursore verso il basso di <L> linee"
    echo
    echo -e "\e[1m<C>C\e[0m"
    echo -e "Sposta il cursore avanti di <C> colonne"
    echo
    echo -e "\e[1m<C>D\e[0m"
    echo -e "Sposta il cursore indietro di <C> colonne"
    echo
    echo -e "\e[1ms\e[0m"
    echo -e "Salva la posizione del cursore (non funziona su tutti i terminali)"
    echo
    echo -e "\e[1mu\e[0m"
    echo -e "Ripristina la posizione del cursore (non funziona su tutti i terminali)"
    echo
    echo -e "\e[4mEsempio d'uso:\e[0m"
    echo
    echo -e "\e[1m$0 \"4;12H\"\e[0m"
    echo -e "Posiziona il cursore alla linea 4, colonna 12"
    echo
    exit 1
fi

echo -ne "\e[${1}"
