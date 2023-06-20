
# awitas
````
   __ ___      _(_) |_ __ _ ___ 
  / _` \ \ /\ / / | __/ _` / __|
 | (_| |\ V  V /| | || (_| \__ \
  \__,_| \_/\_/ |_|\__\__,_|___/ byTux0
  Ataque WPS transparente con rogue AP   

````
![awitas](https://i.postimg.cc/J0MZHcRv/awitass.png"awitas")
Ataque WPS transparente con rogue AP 

Es una herramienta de auditría wireless válida para profesionales y para auditar nuestras propias redes y su seguridad.

Un script guiado para llevar a cabo el ataque evil twin o rogue AP. La diferencia es que no se le pide la clave WPA al usuario. En su lugar se le pide que pulse el botón WPS de su router.
Para que el atque sea efectivo se requiere cercanía a nuestros objetivos y que el usuario atacado caiga en la trampa que se le monta.

Cuenta con la peculiaridad de que a los clientes windows (10 y 11) se les puede montar un punto de acceso falso protegido con WPA, lo que hace más creíble la trampa. La conexión para el usuario es transparente y mediante WPS.

Awitas está inspirado en el trabajod e Koala:
https://github.com/Koala633/hostbase/tree/master/hostbase-1.4ES

------------


# Novedades:
- Soporte para 2,4 GHz y 5 GHz.
- Elección entre aireplay para ataque dirigido a un cliente, o mdk4 para ataque a todos los clientes de la red. (No en openwrt)
- Dejamos de depender de programas externos a los repositorios.
- Compatibilidad con OpenWrt y Wifislax. Probado en Openwrt, wifislax, kali_arm Parrot_arm, kali, parrot, raspOS.
- Mejoras en la información del target.
- Mejoras varias.

------------


# Requerimientos
Es preciso contar con al menos 2 dispositivos wifi. 1 de ellos debe soportar el modo punto de acceso y el otro debe permitir inyección de paquetes.

------------


# Documentación
 (Versión desactualizada.)
Instalación y uso de awitas: <br>
https://www.youtube.com/watch?v=3DR7mcSR4Oo

------------


# Openwrt

Testado en:
- *glinet ar150*
- *netgear r6100*


------------



# Instalación 


Descargamos proyecto

**En debian, Wifislax ( Wifislax, Kali, Parrot, raspOS )**
```
git clone https://github.com/javierbu/awitas.git
cd awitas
```
**En openwrt**

Descargamos en proyecto en nuestro equipo y lo pasamos al dispositivo con openwrt. Ej.
```
git clone https://github.com/javierbu/awitas.git
scp -r awitas/ root@192.168.1.1:/root/
ssh root@192.168.1.1
cd awitas
```

Instalamos dependencias y ejecutamos:


**En debian ( Kali, Parrot, raspOS )**
```
sudo bash dependencias.sh
sudo bash awitas.sh
```
**En openwrt**
```
ash dependencias_ow.sh
bash awitas.sh
```
**En Wifislax**

No es necesario instalar dependencias.


```
bash awitas.sh
```

------------



# Notas de interés

- En la cabecera del script puedes configurar algunas cosas que quizá te vengan bien.
- Se crea una carpeta /tmp/awitas/ donde se almacenan distintas variables y salidas de comandos importantes. Muy útil para depurar si algo no funciona.
- No todos los chipsets funcionan de igual manera. Asegúrate que el chipset de tu dispositivo es capaz de hacer lo que le vas a pedir.


------------



   


[7]: http://https://i.postimg.cc/MTdQ1mCM/awitas.png
[6]: https://i.postimg.cc/MTdQ1mCM/awitas.png
