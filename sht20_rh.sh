#!/bin/bash

# SHT20
# Lettura di Umidita`

loop="reset"
RHread=""
iloop=0
lsb=""

# RH
#echo "Reading Umidita`"
i2cset -y 1 0x40 0xF5
sleep 1
while [[ $loop != "0x00" ]]
  do
    loop=`i2cget -y 1 0x40`
    #echo $loop
    if (( $iloop == 1 ))
      then
        let "iloop += 1"
        #echo $iloop
        RHread=$RHread${loop:2:1}
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
        RHread=$RHread$lsb # aggiunta della stringa/valore ottenuto
        #echo $RHread
    fi
    if (( $iloop < 1 ))
      then
        let "iloop += 1"
        #echo $iloop
        RHread=$RHread${loop:2}
        #echo $RHread
    fi
done

# Devo trasformare le lettere in maiuscolo senno` "bc" non funziona
RHreadM=`echo $RHread | tr [:lower:] [:upper:]`
# Conversione da somma degli hex in decimale
RHhexsum2dec=`echo "ibase=16;$RHreadM" | bc`
# Calcolo da formula nel datasheet di SHT20
# scale=3 taglia alla terza cifra decimale (non arrotonda, taglia e basta)
RH=`echo "scale=3;-6+125*$RHhexsum2dec/2^16" | bc -l`
# Uso il "-n" perche` non voglio il ritorno a capo
echo -n $RH

#echo -n "Umidita\`: "
#echo $RH
