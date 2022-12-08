# awitas
```
   __ ___      _(_) |_ __ _ ___ 
  / _` \ \ /\ / / | __/ _` / __|
 | (_| |\ V  V /| | || (_| \__ \
  \__,_| \_/\_/ |_|\__\__,_|___/ byTux0
  Ataque WPS transparente con rogue AP   

```

Ataque WPS transparente con rogue AP 

Awitas es un script para, mediante un rogueAP, consigamos la llave wpa de un cliente. Solo necesitamos que el cliente pulse el botón de WPS de su dispositivo.
Podemos crear un falso punto de acceso con proteccion wpa, o podemos crear uno abierto.
El protegido es para los clientes windows, para dar credibilidad al engaño.
De momento no soporta 5Ghz. No tengo dispositivo para ello. Quizá en un futuro.

# Requerimientos
Es preciso contar con al menos 2 dispositivos wifi. 1 de ellos debe soportar el modo punto de acceso y el otro debe permitir inyección de paquetes.

Está desarrollado sobre kali linux. Solo se ha probado en kali linux de escritorio, y en su versión para Raspberry. Si dispones de una Raspberry, puedes echar un vistazo al proyecto STAPi (awitas está integrado).<br>
 https://github.com/javierbu/STAPi_r

# Documentación

Instalación y uso de awitas: <br>
https://www.youtube.com/watch?v=3DR7mcSR4Oo

# Soporte

Cualquier duda, sugerencia, problema o comentario, este es el hilo del soporte de awitas:<br>
https://www.wifi-libre.com/topic-1692-awitas-ataque-a-wps-con-rogueap-potegido-con-wpa.html#p16024

# Instalación

Instalamos dependencias
```
sudo apt update && sudo apt install hostapd berate-ap libmicrohttpd-dev build-essential
```

Descargamos e instalamos nodogsplash
```
git clone https://github.com/nodogsplash/nodogsplash.git
cd nodogsplash
make
sudo make install
```
Nos vamos a nuestra carpeta /home
```
cd

```

Descargamos awitas
```
git clone https://github.com/javierbu/awitas.git
```

Entramos en la carpeta y usamos
```
cd awitas
sudo ./awitas
```
