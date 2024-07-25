# awitas

![awitas](https://i.postimg.cc/rmgdPd6t/awwitas.png"awitas")
Ataque WPS transparente con rogue AP 

Es una herramienta de auditoría wireless válida para profesionales y para auditar nuestras propias redes y su seguridad.

Un script guiado para llevar a cabo el ataque evil twin o rogue AP. La diferencia respecto a los proyectos existentes habituales es que no se le pide la clave WPA al usuario. En su lugar se le pide que pulse el botón WPS de su router y de esa manera conseguiremos la clave.
Para que el ataque sea efectivo se requiere cercanía a nuestros objetivos y que el usuario atacado caiga en la trampa que se le monta.

Cuenta con la peculiaridad de que a los clientes Windows (10 y 11) se les puede montar un punto de acceso falso protegido con WPA, lo que hace más creíble la trampa. La conexión para el usuario es transparente y mediante WPS.

Awitas está inspirado en el trabajo de Koala:
https://github.com/Koala633/hostbase

------------

# Novedades:
- Soporte para 2,4 GHz y 5 GHz.
- Elección entre aireplay para ataque dirigido a un cliente, o mdk4 para ataque a todos los clientes de la red. (No en openwrt)
- Dejamos de depender de programas externos a los repositorios.
- Compatibilidad con OpenWRT y Wifislax. Probado en OpenWRT, Wifislax, Kali Linux (ARM) Parrot Security OS (ARM), Kali Linux, Parrot Security OS, Raspberry Pi OS (Raspbian / RaspOS).
- Mejoras en la información del target.
- Mejoras varias.

------------

# Requerimientos
Es preciso contar con al menos 2 dispositivos wifi. 1 de ellos debe soportar el modo punto de acceso y el otro debe permitir inyección de paquetes y ataque de desautenticación.

------------


# Documentación
 
Instalación y uso de awitas: <br>
https://www.youtube.com/watch?v=iBe-aV4MNiQ

------------

# Openwrt

Importante: Para la ejecución de awitas en OpenWRT, es necesario que el/los dispositivo/s wifi del router no estén trabajando, ni en modo cliente ni en modo máster.

------------

# Instalación 

Descargamos proyecto

**En Debian, Wifislax ( Wifislax, Kali, Parrot, raspOS )**
```
git clone https://github.com/javierbu/awitas.git
cd awitas
```

Instalamos dependencias y ejecutamos:

**En Debian ( Kali, Parrot, raspOS )**
```
sudo bash dependencias.sh
sudo bash awitas.sh
```

**En OpenWRT**

Descargamos en proyecto en nuestro equipo y lo pasamos al dispositivo con OpenWRT. Ej.
```
git clone https://github.com/javierbu/awitas.git
scp -r awitas/ root@192.168.1.1:/root/
ssh root@192.168.1.1
cd awitas
```

Instalamos dependencias y ejecutamos:
**En openwrt**
```
ash dependencias_ow.sh
bash awitas.sh
```

**En Wifislax**

No es necesario instalar dependencias. Ejecutamos:
```
bash awitas.sh
```

------------

# Notas de interés

- En la cabecera del script puedes configurar algunas cosas que quizá te vengan bien.
- Se crea una carpeta /tmp/awitas/ donde se almacenan distintas variables y salidas de comandos importantes. Muy útil para depurar si algo no funciona.
- No todos los chipsets funcionan de igual manera. Asegúrate que el chipset de tu dispositivo es capaz de hacer lo que le vas a pedir.


------------

# Últimos cambios

25-Julio-2024
- Se añade soporte para routers Askey RTF3505VW y RTF8115VW gracias a  [danielcshn](https://github.com/danielcshn) por el aporte.
- Se soluciona problema de detección de Parrot Security 6.1 (lorikeet).
- Se añade animación de descarga de archivo oui.txt.
- Mejoras de ortografía, espaciado y sangría.

17-Abril-2024
- Se prescinde (por fin) de airmon-ng
- Se repara ataque con mdk4
- Mejoras de ortografía, guías y varias.

4-abril-2024
- Se compatibiliza a las versiones actuales de openwrt. Hubo problemas en las últimas actualizaciones ya que cambiaron algunos parámetros en el firewall y actualizaron a dnsmasq 2.90. Esto dio algunos problemas, pero ya están solucionados.
- Se repara la opción de descargar el archivo oui.txt cuando estamos conectados a internet a través de wifi.
- Se añade un modelo ZTE h3600P (DIGI) de router parea ataque concreto al router.