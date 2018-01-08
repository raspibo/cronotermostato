#!/bin/bash

# $0
#
# Raspberry Pi Details:
#   Type: Model A+, Revision: 01, Memory: 256MB, Maker: Sony 
#   * Device tree is enabled.
#   *--> Raspberry Pi Model A Plus Rev 1.1
#   * This Raspberry Pi supports user-level GPIO access.
#
# Legge temperatura e umidita` dal sensore SHT20
# Visualizza su un piccolo display
# Trasmette i valori via MQTT alla centralina "Livello 1"
# Gestisce un'uscita per comando riscaldamento

# Display 128x128
# 8 righe , 16 colonne

# Ho usato una generazione random di colori per i testi
# (per evitare un salvaschermo, visto che non intendo
# spegnere/accendere mai il display)

# Uso la GPIO con numerazione BCM non wPi
# e` il parametro "-g" dato al comando gpio (vedi configurazione)

# T temperatura
# RH umidita`
# KA rele`

# Carico la configurazione
# il lampeggio non funziona, per  qualche strano motivo legato a configurazioni di terminale
cecho.sh "5" "Loading config .."
source cronotermostato.conf
sleep 1

# Prevedo queste variabili perche` sono usate in vari parti del programma 
T="15"       # Serve un default per evitare sul primo giro un'errore di script
RH=""        #
Tset="15.2"  # Serve un default per evitare sul primo giro un'errore di script

secMemCyc=0  # Memoria secondi ciclo SHT20
secMemTermo=0  # Memoria secondi ciclo cronotrmostato
Tmem=""
RHmem=""
KAmem=""
Tsetmem=""

# Array che uso per visualizzare il testo invece del valore
KA01=(off on)

# Tasto premuto
key=""

# Configuro il Pin di Uscita comando rele`
gpio $GPIOTYPE mode $KAout out

# Setup (to frambuffer console)
setterm --cursor off
# Enable fb console
con2fbmap $FB 1

clear # Cancello schermo

#Loop infinito
while [[ $key != "q" ]]
  do
    ### Display
    # ogni NN secondi
    if [[ $((`date +%s` - $secMemCyc)) -gt $secUpdateLCD ]]
      then
        T=`sht20_t.sh`
        RH=`sht20_rh.sh`
        KA=`gpio -g read $KAin`
        # MQTT
        if [[ $MQTTENABLE == "1" ]]
          then
            # Aggiorno/invio dati solo se i valori sono cambiati
            if [[ $T != $Tmem ]]
              then
                mosquitto_pub -h $MQTTSERVER -t $TOPIC/Temperatura -m "{ \"ID\" : \"$IDT\", \"Valore\" : \"$T\" }"
                Tmem=$T
            fi
            if [[ "$RH" != "$RHmem" ]]
              then
                mosquitto_pub -h $MQTTSERVER -t $TOPIC/Umidita -m "{ \"ID\" : \"$IDRH\", \"Valore\" : \"$RH\" }"
                RHmem=$RH
            fi
            if [[ "$KA" != "$KAmem" ]]
              then
                mosquitto_pub -h $MQTTSERVER -t $TOPIC/Relay -m "{ \"ID\" : \"$IDKA\", \"Valore\" : \"$KA\" }"
                KAmem=$KA
            fi
        fi
        clear
        mvcursor.sh "1;1H"
        cecho.sh "$(shuf -i 31-37 -n 1)" "$(date +"%Y/%m/%d %H:%M")"
        mvcursor.sh "3;1H"
        cecho.sh "$(shuf -i 31-37 -n 1)" "Temperatura: "
        mvcursor.sh "4;11H"
        cecho.sh "$(shuf -i 31-37 -n 1)" $T
        mvcursor.sh "5;1H"
        cecho.sh "$(shuf -i 31-37 -n 1)" "Umidita\`: "
        mvcursor.sh "5;11H"
        cecho.sh "$(shuf -i 31-37 -n 1)" $RH
        mvcursor.sh "7;1H"
        cecho.sh "$(shuf -i 31-37 -n 1)" "Relay: "
        mvcursor.sh "7;11H"
        cecho.sh "$(shuf -i 31-37 -n 1)" ${KA01[$KA]}
        mvcursor.sh "8;1H"
        cecho.sh "$(shuf -i 31-37 -n 1)" "SetPoint: "
        mvcursor.sh "8;11H"
        cecho.sh "$(shuf -i 31-37 -n 1)" "$Tset"
        # aggiorna variabile
        secMemCyc=`date +%s`
    fi
    ### CronoTermostato
    # ogni NN secondi
    if [[ $((`date +%s` - $secMemTermo)) -gt $secCycTermo ]]
      then
        # Sto` usando/Avevo usato %a, causa lingua uso %u
        # e ho cambiato il file di programmazione
        now=(`date "+%u %H:%M"`)
        while read line
          do
            #echo "$line"
            linea=($line)
            if [[ ${now[0]} == ${linea[0]} ]]
              then
                # Se maggior o uguale
                if [[ ${now[1]} > ${linea[1]} ]] || [[ ${now[1]} == ${linea[1]} ]]
                  then
                    #echo "${linea[@]}"
                    #echo "Giorno: ${linea[0]}"
                    #echo "Ore/Minuti: ${linea[1]}"
                    #echo "Set Temperatura: ${linea[2]}"
                    Tset="${linea[2]}"
                    #echo "Set Point (to): $Tset"
                fi
            fi
        done < $PRGFILE
        # Comando uscita
        if [[ $Tset > $T ]]
          then
            #echo -e "Set Point Temperatura: $Tnow"
            gpio $GPIOTYPE write $KAout 1
          else
            gpio $GPIOTYPE write $KAout 0
        fi
        # MQTT
        if [[ "$MQTTENABLE" == "1" ]]
          then
            ## Aggiorno/invio dati solo se i valori sono cambiati
            if [[ "$Tset" != "$Tsetmem" ]]
              then
                mosquitto_pub -h $MQTTSERVER -t $TOPIC/Temperatura -m "{ \"ID\" : \"$IDSP\", \"Valore\" : \"$Tset\" }"
                Tsetmem=$Tset
            fi
        fi
        secMemTermo=`date +%s`  # aggiorna variabile
    fi
    ### Tastiera/Comandi
    # Legge se e` stato premuto qualche tasto e lo memorizza nella variabile
    # -s no echo, non funziona nello script, vabe`, pazienza
    # -t1 attende un secondo e poi prosegue
    # -n1 accetta/legge un solo carattere per/nella variabile
    read -s -t1 -n1 key
    # Modifica programma settimanale
    if [[ $key == "e" ]]
      then
        clear
        # File temporaneo
        TMPFILE=${PRGFILE%.txt}.tmp
        setterm --cursor on
        # edit
        mcedit $PRGFILE
        # Ricopio le righe d'intestazione e i commenti
        sed -n '/^#/p' < $PRGFILE > $TMPFILE
        # Prendo le righe di programma e le riordino
        sed -e '/^#/d' -e '/^$/d' < $PRGFILE | sort >> $TMPFILE
        # Infine, ricopio il file
        cat $TMPFILE > $PRGFILE
        setterm --cursor off
        # Rileggo tasto, altrimenti interviene la primaria e devo premere un enter per proseguire
        read -t 1 -n 1 key > /dev/null
    fi
    # Visualizza la programmazione attuale del giorno
    if [[ $key == "v" ]]
      then
        now=(`date "+%u"`)
        clear
        while read line
          do
            linea=($line)
            if [[ ${now[0]} == ${linea[0]} ]]
              then
                echo "${linea[@]}"
            fi
        done < $PRGFILE
        # Rileggo tasto, altrimenti interviene la primaria e devo premere un enter per proseguire
        read -s -t 1 -n 1 key
    fi
    ## Help
    # se "h" oppure un tasto non riconosciuto fra i precedenti e non e` "q" (quit)
    if [[ $key == "h" ]] || [[ $key != "" ]] && [[ $key != "q" ]]
      then
        clear
        help.sh
    fi
done

# Return to normal console
clear
con2fbmap $FB 0
setterm --cursor on
exit 0
