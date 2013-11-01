#!/bin/bash

#Script compare captcha
#Please before run this script. You should add the following lines into file /home2/nguyenki/public_html/lib/captcha/captcha.php (starting from line 278)
## $fh = fopen("/home2/nguyenki/public_html/rand.log", 'w+');
## $stringData = $_SERVER["REMOTE_ADDR"]." ".microtime(1)." ".$this->cId." ".$this->sCode."\n";
## fwrite($fh, $stringData);
## fclose($fh);

SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
#for f in *
while :
do
        ORI=`cat rand.log`

        KEY=`cat rand.log | cut -d ' ' -f4`

        OBJECT_STRING=`cat rand.log | cut -d ' ' -f3`

        OBJECT_STRING_DB=`mysql -unguyenki_user1 -h10.10.10.52 -p"I{YOM5q|vi" -e "select object_string from nguyenki_mdb.eraincart_ekeys where ekey='$KEY' and object_string='$OBJECT_STRING';"`

        [ "$KEY" ] || continue

        [ "$OBJECT_STRING" ] || continue

        [ "$OBJECT_STRING_DB" ] && echo "$ORI-----> ok" || echo "$ORI ----> not matched"

        sleep 1

done

IFS=$SAVEIFS
