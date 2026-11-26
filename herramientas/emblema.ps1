# Dibuja el emblema de Gecko Apps en PNG: anillo, texto curvo y el gecko del logo original.
# Se dibuja BLANCO sobre transparente para poder teñirlo del color que sea desde CSS.
#
# El nombre va repartido: una palabra arriba y otra abajo (GECKO / APPS). Así el emblema
# no repite el nombre completo dos veces, y para una submarca basta cambiar la de abajo
# (GECKO / GAMES) sin tocar nada más.
#
# -Estilo elige cómo se reparte la banda alrededor:
#   clasico     arriba dos líneas finas, abajo banda rellena con la palabra calada
#   invertido   al revés: la banda rellena arriba
#   banda       banda rellena todo alrededor, las dos palabras caladas
#   lineas      sin relleno, solo dos aros finos y las dos palabras sólidas
#   partida     banda rellena arriba y abajo, con un hueco y un rombo a cada lado
param(
  [string]$GeckoPng = "H:\Documentos E\Github\BR105.github.io\assets\gecko.png",
  [string]$Salida   = "H:\Documentos E\Github\BR105.github.io\assets\emblema.png",
  [string]$Arriba   = "GECKO",
  [string]$Abajo    = "APPS",
  [ValidateSet('clasico','invertido','banda','lineas','partida')]
  [string]$Estilo   = "clasico",
  [int]$Lado        = 1024,
  [string]$Tipo     = "Bahnschrift",
  # Tipografía del texto curvo. Se carga del archivo, sin instalarla en Windows, para que
  # el emblema salga igual en cualquier PC. Si no está, se usa -Tipo.
  [string]$Ttf      = "$PSScriptRoot\Montserrat-Bold.ttf"
)
Add-Type -AssemblyName System.Drawing

$S = $Lado; $c = $S / 2.0
$rExt = $S * 0.4805      # borde exterior de la banda
$rInt = $S * 0.3750      # borde interior de la banda
$rTxt = $S * 0.4300      # línea base del texto curvo
$rAro = $S * 0.3145      # aro interior
$grAro = $S * 0.0225
$grLin = $S * 0.0075
$fuente = $S * 0.0720    # una sola palabra por lado: cabe más grande que antes
$tracking = $S * 0.0120  # espacio extra entre letras

$bmp = New-Object System.Drawing.Bitmap $S, $S
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = 'AntiAlias'
$g.TextRenderingHint = 'AntiAliasGridFit'
$g.InterpolationMode = 'HighQualityBicubic'
$g.Clear([System.Drawing.Color]::Transparent)

$blanco = [System.Drawing.Color]::White
$brBlanco = New-Object System.Drawing.SolidBrush $blanco
$plumaFina = New-Object System.Drawing.Pen $blanco, $grLin
$plumaAro  = New-Object System.Drawing.Pen $blanco, $grAro
$rMed = ($rExt + $rInt) / 2.0

# Recorta a un sector del círculo. Los ángulos de GDI+ van en grados y crecen en el
# sentido del reloj desde las 3; 180..360 es la mitad de arriba, 0..180 la de abajo.
function Sector([double]$desde, [double]$barrido){
  $r = New-Object System.Drawing.Drawing2D.GraphicsPath
  $r.AddPie([single]($c-$rExt-2), [single]($c-$rExt-2), [single](($rExt+2)*2), [single](($rExt+2)*2),
            [single]$desde, [single]$barrido)
  $g.SetClip($r)
  $r.Dispose()
}

function BandaArco([double]$desde, [double]$barrido){
  Sector $desde $barrido
  $pluma = New-Object System.Drawing.Pen $blanco, ($rExt - $rInt)
  $g.DrawEllipse($pluma, [single]($c-$rMed), [single]($c-$rMed), [single]($rMed*2), [single]($rMed*2))
  $pluma.Dispose()
  $g.ResetClip()
}

function LineasArco([double]$desde, [double]$barrido){
  Sector $desde $barrido
  # Se meten media línea hacia dentro para que su borde coincida EXACTO con el de la
  # banda rellena: si se dibujan sobre el radio, sobresalen grLin/2 y el corte se rompe.
  foreach($r in @(($rExt - $grLin/2), ($rInt + $grLin/2))){
    $g.DrawEllipse($plumaFina, [single]($c-$r), [single]($c-$r), [single]($r*2), [single]($r*2))
  }
  $g.ResetClip()
}

# Rombo pequeño, centrado en el medio de la banda, al ángulo que se le pase (en grados).
function Rombo([double]$grados, [bool]$quitar){
  $a = $grados * [Math]::PI / 180.0
  $x = $c + $rMed * [Math]::Cos($a)
  $y = $c + $rMed * [Math]::Sin($a)
  $t = ($rExt - $rInt) * 0.34
  $st = $g.Save()
  $g.TranslateTransform([single]$x, [single]$y) | Out-Null
  $g.RotateTransform(45) | Out-Null
  if($quitar){ $g.CompositingMode = 'SourceCopy'; $pincel = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::Transparent) }
  else { $pincel = $brBlanco }
  $g.FillRectangle($pincel, [single](-$t), [single](-$t), [single]($t*2), [single]($t*2))
  if($quitar){ $g.CompositingMode = 'SourceOver'; $pincel.Dispose() }
  $g.Restore($st)
}

# --- tipografía ---
$coleccion = $null
if (Test-Path $Ttf) {
    $coleccion = New-Object System.Drawing.Text.PrivateFontCollection
    $coleccion.AddFontFile($Ttf)
    $fam = $coleccion.Families[0]
} else {
    try { $fam = New-Object System.Drawing.FontFamily $Tipo }
    catch { $fam = New-Object System.Drawing.FontFamily "Segoe UI" }
}
$fnt = New-Object System.Drawing.Font $fam, $fuente, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
$fmt = [System.Drawing.StringFormat]::GenericTypographic
$fmt.Alignment = 'Center'

function Ancho([string]$s){
  $t = 0.0
  foreach($ch in $s.ToCharArray()){
    $t += $g.MeasureString([string]$ch, $fnt, [System.Drawing.PointF]::Empty, $fmt).Width + $tracking
  }
  return $t - $tracking
}

# Dibuja cada letra girada sobre el arco. 'quitar' = la borra (para la banda rellena).
function DibujarArco([string]$texto, [bool]$abajo, [bool]$quitar){
  if([string]::IsNullOrWhiteSpace($texto)){ return }
  $ancho = Ancho $texto
  $barrido = $ancho / $rTxt                     # radianes que ocupa el texto
  $centroAng = if($abajo){ [Math]::PI/2 } else { -[Math]::PI/2 }
  $dir = if($abajo){ -1.0 } else { 1.0 }        # abajo va al revés: se lee de izquierda a derecha
  $ang = $centroAng - $dir * $barrido/2.0

  if($quitar){ $g.CompositingMode = 'SourceCopy'; $pincel = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::Transparent) }
  else { $pincel = $brBlanco }

  foreach($ch in $texto.ToCharArray()){
    $w = $g.MeasureString([string]$ch, $fnt, [System.Drawing.PointF]::Empty, $fmt).Width
    $paso = ($w + $tracking) / $rTxt
    $a = $ang + $dir * $paso/2.0
    $x = $c + $rTxt * [Math]::Cos($a)
    $y = $c + $rTxt * [Math]::Sin($a)
    $st = $g.Save()
    $g.TranslateTransform([single]$x, [single]$y) | Out-Null
    $ajuste = if($abajo){ -90.0 } else { 90.0 }
    $g.RotateTransform([single](($a * 180.0 / [Math]::PI) + $ajuste))
    # Contorno real de la letra: al recortar, se borra la forma, no su caja.
    # Se centra por su caja real (GetBounds), no por la caja del tipo: así la letra
    # queda justo en medio de la banda y no pegada al borde de afuera.
    if([string]$ch -ne " "){
      $ruta = New-Object System.Drawing.Drawing2D.GraphicsPath
      $ruta.AddString([string]$ch, $fam, [int][System.Drawing.FontStyle]::Bold, [single]$fuente, (New-Object System.Drawing.PointF 0, 0), $fmt)
      $bb = $ruta.GetBounds()
      $m = New-Object System.Drawing.Drawing2D.Matrix
      $m.Translate([single](-($bb.X + $bb.Width/2)), [single](-($bb.Y + $bb.Height/2)))
      $ruta.Transform($m)
      $g.FillPath($pincel, $ruta)
      $m.Dispose(); $ruta.Dispose()
    }
    $g.Restore($st)
    $ang += $dir * $paso
  }
  if($quitar){ $g.CompositingMode = 'SourceOver'; $pincel.Dispose() }
}

# --- el aro de alrededor, según el estilo ---
$calarArriba = $false; $calarAbajo = $false
switch($Estilo){
  'clasico'   { LineasArco 180 180; BandaArco 0 180; $calarAbajo = $true }
  'invertido' { BandaArco 180 180; LineasArco 0 180; $calarArriba = $true }
  'banda'     { BandaArco 0 360; $calarArriba = $true; $calarAbajo = $true }
  'lineas'    { LineasArco 0 360; Rombo 0 $false; Rombo 180 $false }
  'partida'   { BandaArco 194 152; BandaArco 14 152; $calarArriba = $true; $calarAbajo = $true }
}

# --- aro interior ---
$g.DrawEllipse($plumaAro, [single]($c-$rAro), [single]($c-$rAro), [single]($rAro*2), [single]($rAro*2))

# --- el gecko, centrado ---
$gk = [System.Drawing.Image]::FromFile($GeckoPng)
$lg = $S * 0.50
$g.DrawImage($gk, [single]($c - $lg/2), [single]($c - $lg/2), [single]$lg, [single]$lg)
$gk.Dispose()

# --- las dos palabras ---
DibujarArco $Arriba $false $calarArriba
DibujarArco $Abajo  $true  $calarAbajo

# en 'banda' y 'partida' los rombos van calados, sobre el relleno de los costados
if($Estilo -eq 'banda'){ Rombo 0 $true; Rombo 180 $true }
if($Estilo -eq 'partida'){ Rombo 0 $false; Rombo 180 $false }

$bmp.Save($Salida, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose(); $fnt.Dispose()
if ($coleccion) { $coleccion.Dispose() }
Write-Output ("{0}: {1} bytes" -f $Estilo, (Get-Item $Salida).Length)
