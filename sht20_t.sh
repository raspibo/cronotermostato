#!/bin/bash

# SHT20
# Lettura di Temperatura

loop="reset"
Tread=""
iloop=0
lsb=""

# T
#echo "Reading Temperature"
i2cset -y 1 0x40 0xF3
sleep 1
while [[ $loop != "0x00" ]]
  do
    loop=`i2cget -y 1 0x40`
    #echo $loop
    if (( $iloop == 1 ))
      then
        let "iloop += 1"
        #echo $iloop
        Tread=$Tread${loop:2:1}
        # Calcolo della seconda parte del dato LSB
        # gli ultimi due bit sono segnali di stato
        # quindi si deve fare un "and" con bit a '0'
        #     byte & 1100
        lsb=${loop:3:1} # estrazione della quarta lettera
        #echo "lsb: $lsb"
        lsb16=`echo "ibase=16;$lsb" | bc` # conversione a decimale
        #echo "lsb16: $lsb16"
        lsband=$(($lsb16 & 12)) # AND (12 decimale e` 1100 binario)
        #echo "lsband: $lsband"
        lsb=`echo "ibase=10;obase=16;$lsband" | bc` # riconversione a esadecimale del risultato
        #echo "lsb: $lsb"
        Tread=$Tread$lsb # aggiunta della stringa/valore ottenuto
        #echo $Tread
    fi
    if (( $iloop < 1 ))
      then
        let "iloop += 1"
        #echo $iloop
        Tread=$Tread${loop:2}
        #echo $Tread
    fi
done

# Devo trasformare le lettere in maiuscolo senno` "bc" non funziona
TreadM=`echo $Tread | tr [:lower:] [:upper:]`
# Conversione da somma degli hex in decimale
Thexsum2dec=`echo "ibase=16;$TreadM" | bc`
# Calcolo da formula nel datasheet di SHT20
# scale=3 taglia alla terza cifra decimale (non arrotonda, taglia e basta)
T=`echo "scale=3;-46.85+175.72*$Thexsum2dec/2^16" | bc -l`
# Uso il "-n" perche` non voglio il ritorno a capo
echo -n $T

#echo -n "Temperatura: "
#echo $T
