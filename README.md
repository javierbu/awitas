# awitas
```
   __ ___      _(_) |_ __ _ ___ 
  / _` \ \ /\ / / | __/ _` / __|
 | (_| |\ V  V /| | || (_| \__ \
  \__,_| \_/\_/ |_|\__\__,_|___/ byTux0
  Ataque WPS transparente con rogue AP   

```

Ataque WPS transparente con rogue AP 

Awitas es un script para, mediante un ataque evil twin, consigamos la llave wpa de un cliente. Solo necesitamos que el cliente pulse el botón de WPS de su dispositivo.
Podemos crear un falso punto de acceso con proteccion wpa, o podemos crear uno abierto.
El protegido es para los clientes windows, para dar credibilidad al engaño.

# Novedades:
- Soporte para 2,4 GHz y 5 GHz.
- Elección entre aireplay para ataque dirigido a un cliente, o mdk4 para ataque a todos los clientes de la red.
- Soporte otros sistemas operativos: probado en Parrot (v.5.1.2) tanto en versión para raspberry como versión escritorio. Kali linux (v.2022.4) Tanto en versión para raspberry como en versión escritorio. RaspiOS bullseye (2022-9-22). Debería funcionar en cualquier sistema basado en debian, y posiblemente en otros.

# Requerimientos
Es preciso contar con al menos 2 dispositivos wifi. 1 de ellos debe soportar el modo punto de acceso y el otro debe permitir inyección de paquetes.

 Si dispones de una Raspberry, puedes echar un vistazo al proyecto STAPi (awitas está integrado).<br>
 https://github.com/javierbu/STAPi_r

# Documentación

Instalación y uso de awitas (version antigua): <br>
https://www.youtube.com/watch?v=3DR7mcSR4Oo

# Soporte

Cualquier duda, sugerencia, problema o comentario, este es el hilo del soporte de awitas:<br>
https://www.wifi-libre.com/topic-1692-awitas-ataque-a-wps-con-rogueap-potegido-con-wpa.html#p16024

# Instalación

Instalamos dependencias
```
sudo apt update && sudo apt install mdk4 hostapd git aircrack-ng libmicrohttpd-dev build-essential net-tools
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

# Notas de interés

- El script está pensado para raspberry administrada por ssh en un principio. Por ello todo se ejecuta desde una sola consola sin ventanas emergentes.
- En la cabecera del script puedes configurar algunas cosas que quizá te vengan bien.
- Se crea una carpeta /tmp/awitas/ donde se almacenan distintas variables y salidas de comandos importantes. Muy útil para depurar si algo no funciona.
- No todos los chipsets funcionan de igual manera. Asegúrate que el chipset de tu dispositivo es capaz de hacer lo que le vas a pedir.

# Sobre chipsets:

Se agradece cualquier información realitva a lo chipsets de los dispositivos usados. Pueden usar el hilo de soporte o cualquier forma de contacto.

- **8814au.** https://github.com/morrownr/8814au . Funciona perfectamente tanto en 2,4 GHz como en 5 GHz. Es válido tanto para la creación de punto de acceso como para el ataque DoS.
- **8812au.** https://github.com/morrownr/8812au-20210629 . Funciona muy bien para la creación del punto de acceso tanto en 5GHz como en 2,4 GHz. No funciona para el ataque DoS. 
- **brcmfmac.** Es el integrado de la raspberry 4b. Funciona muy bien para la creación del punto de acceso en ambas bandas. No sirve para el ataque DoS.
- **ath9k_htc.** Solo trabaja en 2,4 GHz. Funciona muy bien para el ataque DoS. Presenta algunos fallos creando el punto de acceso. Es posible que estos fallos sean en mi dispositivo concreto.
- **rtl8187.** Solo trabaja en 2,4 GHz. Funciona muy bien para el ataque DoS. No soporta la opción de crear punto de acceso.

   

