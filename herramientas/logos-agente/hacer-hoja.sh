#!/bin/bash
# Arma hoja.html metiendo los SVG en linea (las mascaras CSS no cargan en
# Edge headless con file://) y la captura a hoja.png. Tambien exporta cada
# simbolo a NN-nombre.png a 512 px, blanco sobre transparente, igual que
# los PNG de assets/.
set -e
D="$(cd "$(dirname "$0")" && pwd)"
EDGE="/c/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
TAMS="128 64 40 24"

declare -A NOM=( [01-fiel]="01 · Fiel|el original, simplificado"
                 [02-cola-g]="02 · Cola-G|la cola hace la G"
                 [03-huella]="03 · Huella|la mano que trepa"
                 [04-curva]="04 · Curva|una sola forma"
                 [05-cuna]="05 · Cuña|angular, de periférico"
                 [06-mascota]="06 · Mascota|de perfil, con carácter" )
ORDEN="01-fiel 02-cola-g 03-huella 04-curva 05-cuna 06-mascota"

# contenido de un SVG sin su etiqueta <svg> exterior
tripa(){ sed -e '1d' -e '$d' "$D/$1.svg"; }

# --- hoja comparativa ---------------------------------------------------
{
cat <<'CAB'
<!doctype html><meta charset="utf-8"><title>Gecko Apps · hoja comparativa</title>
<style>
 body{margin:0;background:#17171a;color:#e8e8ea;font:13px/1.4 "Segoe UI",system-ui,sans-serif;padding:26px}
 h1{font-size:19px;margin:0 0 4px}
 .nota{color:#8b8b93;font-size:12px;margin:0 0 20px;max-width:900px}
 table{border-collapse:separate;border-spacing:0 10px}
 th{font-size:11px;font-weight:600;color:#8b8b93;text-transform:uppercase;letter-spacing:.08em;padding-bottom:4px}
 .et{width:140px;padding-right:14px;vertical-align:middle}
 .et b{display:block;font-size:14px}.et span{color:#8b8b93;font-size:11px}
 .caja{display:flex;align-items:center;gap:16px;padding:10px 18px;height:148px;box-sizing:border-box}
 .oscuro,.verde{background:#0a0a0c}.claro{background:#fff}
 .tam{font-size:10px;color:#8b8b93;text-align:center;padding-top:5px}
 .claro .tam{color:#9a9aa2}
 svg{display:block}
</style>
<h1>Gecko Apps · seis direcciones de símbolo</h1>
<p class="nota">Dibujados a mano en SVG (viewBox 0 0 120 120), forma sólida monocroma: el color
lo pone una sola tinta, así que sirven igual teñidos desde CSS que los PNG de <code>assets/</code>.
Tamaños: 128 px (referencia), 64 px (ícono de app), 40 px (cabecera del sitio), 24 px (pestaña).
El 512 px de cada uno está en su propio <code>NN-nombre.png</code>.</p>
<table><tr><th></th><th>Blanco sobre #0a0a0c</th><th>Negro sobre blanco</th><th>Verde #35d07f</th></tr>
CAB

for k in $ORDEN; do
  IFS='|' read -r t s <<< "${NOM[$k]}"
  body="$(tripa "$k")"
  echo "<tr><td class=\"et\"><b>$t</b><span>$s</span></td>"
  for tema in oscuro:#fff claro:#000 verde:#35d07f; do
    cls="${tema%%:*}"; col="${tema##*:}"
    echo "<td><div class=\"caja $cls\">"
    for n in $TAMS; do
      echo "<div><svg viewBox=\"0 0 120 120\" width=\"$n\" height=\"$n\" color=\"$col\" xmlns=\"http://www.w3.org/2000/svg\">$body</svg><div class=\"tam\">$n</div></div>"
    done
    echo "</div></td>"
  done
  echo "</tr>"
done
echo "</table>"
} > "$D/hoja.html"

"$EDGE" --headless --disable-gpu --hide-scrollbars --virtual-time-budget=4000 \
  --window-size=1230,1230 --screenshot="$D/hoja.png" "$D/hoja.html" 2>/dev/null

# --- un PNG por direccion, 512 px, blanco sobre transparente ------------
for k in $ORDEN; do
  cat > "$D/_tmp.html" <<EOF
<!doctype html><meta charset="utf-8"><style>html,body{margin:0}</style>
<svg viewBox="0 0 120 120" width="512" height="512" color="#fff" xmlns="http://www.w3.org/2000/svg">$(tripa "$k")</svg>
EOF
  "$EDGE" --headless --disable-gpu --hide-scrollbars --virtual-time-budget=2000 \
    --default-background-color=00000000 --window-size=512,512 \
    --screenshot="$D/$k.png" "$D/_tmp.html" 2>/dev/null
done
rm -f "$D/_tmp.html"
echo "listo"
