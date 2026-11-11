# Dibuja el emblema de Gecko Apps en PNG: anillo, texto curvo y el gecko del logo original.
# Se dibuja BLANCO sobre transparente para poder teñirlo del color que sea desde CSS.
param(
  [string]$GeckoPng = "H:\Documentos E\Github\BR105.github.io\assets\gecko.png",
  [string]$Salida   = "H:\Documentos E\Github\BR105.github.io\assets\emblema.png",
  [string]$Texto    = "GECKO APPS",
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
$fuente = $S * 0.0635
$tracking = $S * 0.0105  # espacio extra entre letras

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

# --- mitad de arriba: dos líneas finas ---
# Se meten media línea hacia dentro para que su borde coincida EXACTO con el de la
# banda rellena: si se dibujan sobre el radio, sobresalen grLin/2 y el corte se rompe.
$g.SetClip((New-Object System.Drawing.RectangleF 0, 0, $S, ($c + 1)))
foreach($r in @(($rExt - $grLin/2), ($rInt + $grLin/2))){
  $g.DrawEllipse($plumaFina, [single]($c-$r), [single]($c-$r), [single]($r*2), [single]($r*2))
}
$g.ResetClip()

# --- mitad de abajo: banda rellena ---
$g.SetClip((New-Object System.Drawing.RectangleF 0, $c, $S, $c))
$plumaBanda = New-Object System.Drawing.Pen $blanco, ($rExt - $rInt)
$rMed = ($rExt + $rInt) / 2.0
$g.DrawEllipse($plumaBanda, [single]($c-$rMed), [single]($c-$rMed), [single]($rMed*2), [single]($rMed*2))
$g.ResetClip()
$plumaBanda.Dispose()

# --- aro interior ---
$g.DrawEllipse($plumaAro, [single]($c-$rAro), [single]($c-$rAro), [single]($rAro*2), [single]($rAro*2))

# --- el gecko, centrado ---
$gk = [System.Drawing.Image]::FromFile($GeckoPng)
$lg = $S * 0.50
$g.DrawImage($gk, [single]($c - $lg/2), [single]($c - $lg/2), [single]$lg, [single]$lg)
$gk.Dispose()

# --- texto curvo ---
# Dibuja cada letra girada sobre el arco. 'quitar' = la borra (para la banda rellena).
$coleccion = $null
if (Test-Path $Ttf) {
    $coleccion = New-Object System.Drawing.Text.PrivateFontCollection
    $coleccion.AddFontFile($Ttf)
    $fam = $coleccion.Families[0]
    Write-Output ("tipografía: {0} (del archivo)" -f $fam.Name)
} else {
    try { $fam = New-Object System.Drawing.FontFamily $Tipo }
    catch { $fam = New-Object System.Drawing.FontFamily "Segoe UI" }
    Write-Output ("tipografía: {0} (instalada)" -f $fam.Name)
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

function DibujarArco([string]$texto, [bool]$abajo, [bool]$quitar){
  $ancho = Ancho $texto
  $barrido = $ancho / $rTxt                     # radianes que ocupa el texto
  $centroAng = if($abajo){ [Math]::PI/2 } else { -[Math]::PI/2 }
  $dir = if($abajo){ -1.0 } else { 1.0 }        # abajo va al revés: queda de cabeza, como el original
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
    $ajuste = 90.0
    if($abajo){ $ajuste = -90.0 }
    $giro = ($a * 180.0 / [Math]::PI) + $ajuste
    $g.RotateTransform([single]$giro)
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

DibujarArco $Texto $false $false   # arriba: letras blancas sobre el fondo
DibujarArco $Texto $true  $true    # abajo: letras recortadas de la banda

$bmp.Save($Salida, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose(); $bmp.Dispose(); $fnt.Dispose()
if ($coleccion) { $coleccion.Dispose() }
Write-Output ("emblema: " + (Get-Item $Salida).Length + " bytes")
