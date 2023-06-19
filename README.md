# awitas
```
   __ ___      _(_) |_ __ _ ___ 
  / _` \ \ /\ / / | __/ _` / __|
 | (_| |\ V  V /| | || (_| \__ \
  \__,_| \_/\_/ |_|\__\__,_|___/ byTux0
  Ataque WPS transparente con rogue AP   

```

Ataque WPS transparente con rogue AP 

Es una herramienta de auditría wireless válida para profesionales y para auditar nuestras propias redes y su seguridad.

Un script guiado para llevar a cabo el ataque evil twin o rogue AP. La diferencia es que no se le pide la clave WPA al usuario. En su lugar se le pide que pulse el botón WPS de su router.
Para que el atque sea efectivo se requiere cercanía a nuestros objetivos y que el usuario atacado caiga en la trampa que se le monta.

Cuenta con la peculiaridad de que a los clientes windows (10 y 11) se les puede montar un punto de acceso falso protegido con WPA, lo que hace más creíble la trampa. La conexión para el usuario es transparente y mediante WPS.

Awitas está inspirado en el trabajod e Koala:
https://github.com/Koala633/hostbase/tree/master/hostbase-1.4ES

# Novedades:
- Soporte para 2,4 GHz y 5 GHz.
- Elección entre aireplay para ataque dirigido a un cliente, o mdk4 para ataque a todos los clientes de la red. (No en openwrt)
- Dejamos de depender de programas externos a los repositorios.
- Compatibilidad con OpenWrt y Wifislax. Probado en Openwrt, wifislax, kali_arm Parrot_arm, kali, parrot, raspOS.
- Mejoras en la información del target.
- Mejoras varias.

# Requerimientos
Es preciso contar con al menos 2 dispositivos wifi. 1 de ellos debe soportar el modo punto de acceso y el otro debe permitir inyección de paquetes.

# Documentación
 (Versión desactualizada.)
Instalación y uso de awitas: <br>
https://www.youtube.com/watch?v=3DR7mcSR4Oo

# Soporte



# Instalación 


Descargamos proyecto
```
git clone https://github.com/javierbu/awitas.git
cd awitas
```
Instalamos dependencias:

En debian ( Kali, Parrot, raspOS )
```
sudo bash dependencias.sh
```
En openwrt
```
ash dependencias_ow.sh
```
En Wifislax no es necesario instalar dependencias.

Uso
```
sudo bash awitas.sh
```

# Notas de interés

- En la cabecera del script puedes configurar algunas cosas que quizá te vengan bien.
- Se crea una carpeta /tmp/awitas/ donde se almacenan distintas variables y salidas de comandos importantes. Muy útil para depurar si algo no funciona.
- No todos los chipsets funcionan de igual manera. Asegúrate que el chipset de tu dispositivo es capaz de hacer lo que le vas a pedir.

# Sobre chipsets:


- **8814au.** https://github.com/morrownr/8814au . Funciona perfectamente tanto en 2,4 GHz como en 5 GHz. Es válido tanto para la creación de punto de acceso como para el ataque DoS.
- **8812au.** https://github.com/morrownr/8812au-20210629 . Funciona muy bien para la creación del punto de acceso tanto en 5GHz como en 2,4 GHz. No funciona para el ataque DoS. 
- **brcmfmac.** Es el integrado de la raspberry 4b. Funciona muy bien para la creación del punto de acceso en ambas bandas. No sirve para el ataque DoS.
- **ath9k_htc.** Solo trabaja en 2,4 GHz. Funciona muy bien para el ataque DoS. Presenta algunos fallos creando el punto de acceso. Es posible que estos fallos sean en mi dispositivo concreto.
- **rtl8187.** Solo trabaja en 2,4 GHz. Funciona muy bien para el ataque DoS. No soporta la opción de crear punto de acceso.

   

