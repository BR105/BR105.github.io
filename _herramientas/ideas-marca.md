# Ideas de marca — Gecko Apps

Cuaderno de lo que vamos decidiendo y de lo que queda por probar. No es
documentación del sitio: es el bote de ideas de la identidad.

## Lo decidido

- **El nombre va repartido en el emblema.** El emblema de siempre dice
  «GECKO APPS» arriba *y* abajo. A partir de ahora: **GECKO arriba, APPS
  abajo**. Con una palabra por lado las letras caben más grandes, y la
  submarca sale cambiando solo la de abajo: **GECKO / GAMES**.
- **El emblema redondo se queda como marca principal.** Se probó sustituirlo
  por un símbolo más simple al estilo Razer o Corsair y no funcionó (ver más
  abajo); el aro con el gecko sigue siendo la marca.
- **Gecko Games conserva el verde del estudio** (`#35d07f`), no lleva color
  propio. Las dos marcas son el mismo estudio: lo único que las separa es la
  palabra de abajo del emblema. Los colores propios siguen siendo de cada
  app (Zynora violeta, Vocyra naranja, Opsira rojo), no de las marcas.
- **Las intros elegidas son dos:** la cinética (las palabras entran por los
  lados y el círculo estalla en medio y se queda de contenedor) y la del
  enjambre (las partículas arman el gecko, se cierran dos anillos y el nombre
  se acomoda sobre la curva). Las dos dibujan el nombre en vivo, así que la
  misma intro sirve para Apps y para Games.
- **El reparto es el «Clásico», y ya está puesto.** Líneas finas arriba con
  GECKO, banda rellena abajo con APPS calado. Mantiene el esqueleto de
  siempre, así que no se siente un logo nuevo, pero ya no repite el nombre.
  Vive en `assets/emblema.png`, y la submarca en `assets/emblema-games.png`.
  Para regenerar cualquiera de los dos:
  `herramientas\emblema.ps1 -Abajo APPS|GAMES -Salida <ruta>`.
  A 24 px ningún emblema conserva las letras: de 40 px para abajo hay que
  usar el gecko solo (`assets/favicon.png`).

## Por probar

### Animación: las letras salen girando de su fondo contrario

Aprovechar que arriba y abajo tienen fondos opuestos (una mitad en líneas,
la otra en banda rellena):

- **GECKO** nace *dentro* de la banda rellena, como texto calado, y va
  girando sobre el aro hasta llegar a su sitio en la mitad de arriba. Según
  avanza, deja de ser hueco y se vuelve sólido: se «revela» al salir del
  relleno.
- **APPS** hace el camino contrario: sale de la mitad en líneas, gira hacia
  abajo y al entrar en la banda se convierte en texto calado.
- Las dos palabras giran al mismo tiempo, en sentidos opuestos, y frenan
  centradas. El cruce ocurre en los costados, donde la banda cambia de
  carácter, que es justo donde el truco se nota.

Nota técnica para cuando toque: el cambio de sólido a calado se puede hacer
con dos copias del texto (una sólida, otra calada) y una máscara que siga al
aro, en vez de intentar animar el recorte letra por letra.

## Cerrado: la marca simple no funcionó

Se intentó dos veces cambiar el gecko por un símbolo más simple, al estilo
Razer o Corsair: una tanda dibujada en la sesión y otra con el agente
`disenador-logos`, diez propuestas en total. **Las dos tandas se rechazaron
enteras.** Entre ellas iba la idea de la **cola haciendo de G**, que venía de
los primeros bocetos; con trazo grueso se lee como una G con bolitas, no como
un gecko, así que esa vía también queda cerrada.

El motivo de fondo: las dos tandas se dibujaron escribiendo coordenadas de
SVG a mano, y así salen formas geométricas, no un bicho con carácter. El
gecko original tiene una curva y una cola que salieron de una mano dibujando.

**El símbolo se queda como está.** Si algún día se quiere un gecko nuevo de
verdad, el camino es un ilustrador o una herramienta de generación de
imágenes, y después pasarlo a vector limpio. No reintentarlo a mano.

Lo único que sí salió del ejercicio: el gecko completo visto desde arriba
**no cabe en 24 px**, tiene demasiados eventos. O el ícono chico es otra
forma, o se hace un sistema de dos pesos (el completo de 128 px para arriba,
uno recortado para abajo).

## Pendiente de decidir

- Qué intro le toca a Gecko Apps y cuál a Gecko Games.
- Pasar la intro elegida a video (MP4 1920×1080, o WebM con transparencia) y
  ver si lleva sonido; el sonido habría que conseguirlo con licencia libre.
