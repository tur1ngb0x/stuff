usage() {
  cat << 'EOF'
Usage:
  fontconfig.sh
    --sans           font
    --serif          font
    --mono           font
    --antialias      true|false
    --autohint       true|false
    --dpi            NUMBER
    --embeddedbitmap true|false
    --hinting        true|false
    --hintstyle      hintnone|hintslight|hintmedium|hintfull
    --rgba           none|rgb|bgr|vrgb|vbgr
    --lcdfilter      none|default|light|legacy

Example:
  fontconfig.sh \
    --sans           'Liberation Sans' \
    --serif          'Liberation Serif' \
    --mono           'Liberation Mono' \
    --antialias      true \
    --autohint       false \
    --dpi            96 \
    --embeddedbitmap true \
    --hinting        true \
    --hintstyle      hintslight \
    --rgba           rgb \
    --lcdfilter      default
EOF
}

# If no args, show usage and exit
if [[ $# -eq 0 ]]; then
  usage
  exit 0
fi

# Defaults (empty = do not write that section)
SANS=""
SERIF=""
MONO=""

ANTIALIAS=""
AUTOHINT=""
DPI=""
EMBEDDEDBITMAP=""
HINTING=""
HINTSTYLE=""
RGBA=""
LCDFILTER=""

escape_xml() {
  local s="$1"
  s="${s//&/&amp;}"
  s="${s//</&lt;}"
  s="${s//>/&gt;}"
  s="${s//\"/&quot;}"
  s="${s//\'/&apos;}"
  printf '%s' "$s"
}

xml_bool() {
  case "$1" in
    true|false) printf '%s' "$1" ;;
    *)
      echo "Error: invalid boolean '$1' (use true|false)" >&2
      exit 2
      ;;
  esac
}

xml_double() {
  local v="$1"
  if [[ "$v" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    printf '%s' "$v"
  else
    echo "Error: invalid number '$v' for --dpi" >&2
    exit 2
  fi
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --sans)
      SANS="${2:-}"
      shift 2
      ;;
    --serif)
      SERIF="${2:-}"
      shift 2
      ;;
    --mono)
      MONO="${2:-}"
      shift 2
      ;;

    --antialias)
      ANTIALIAS="$(xml_bool "${2:-}")"
      shift 2
      ;;
    --autohint)
      AUTOHINT="$(xml_bool "${2:-}")"
      shift 2
      ;;
    --dpi)
      DPI="$(xml_double "${2:-}")"
      shift 2
      ;;
    --embeddedbitmap)
      EMBEDDEDBITMAP="$(xml_bool "${2:-}")"
      shift 2
      ;;
    --hinting)
      HINTING="$(xml_bool "${2:-}")"
      shift 2
      ;;
    --hintstyle)
      HINTSTYLE="${2:-}"
      shift 2
      ;;
    --rgba)
      RGBA="${2:-}"
      shift 2
      ;;
    --lcdfilter)
      LCDFILTER="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

# Validate enum-ish options
case "${HINTSTYLE:-}" in
  ""|hintnone|hintslight|hintmedium|hintfull) ;;
  *)
    echo "Error: invalid --hintstyle '$HINTSTYLE'" >&2
    exit 2
    ;;
esac

case "${RGBA:-}" in
  ""|none|rgb|bgr|vrgb|vbgr) ;;
  *)
    echo "Error: invalid --rgba '$RGBA'" >&2
    exit 2
    ;;
esac

case "${LCDFILTER:-}" in
  ""|none|default|light|legacy) ;;
  *)
    echo "Error: invalid --lcdfilter '$LCDFILTER'" >&2
    exit 2
    ;;
esac

ts="$(date +%Y%m%d-%H%M%S)"
out="./fonts-${ts}.conf"

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

{
  echo '<fontconfig>'
  echo ''
  echo '  <!-- Default font families -->'

  if [[ -n "$SANS" ]]; then
    echo '  <match target="pattern">'
    echo '    <test qual="any" name="family"><string>sans-serif</string></test>'
    echo '    <edit name="family" mode="prepend" binding="strong">'
    echo "      <string>$(escape_xml "$SANS")</string>"
    echo '    </edit>'
    echo '  </match>'
    echo ''
  fi

  if [[ -n "$SERIF" ]]; then
    echo '  <match target="pattern">'
    echo '    <test qual="any" name="family"><string>serif</string></test>'
    echo '    <edit name="family" mode="prepend" binding="strong">'
    echo "      <string>$(escape_xml "$SERIF")</string>"
    echo '    </edit>'
    echo '  </match>'
    echo ''
  fi

  if [[ -n "$MONO" ]]; then
    echo '  <match target="pattern">'
    echo '    <test qual="any" name="family"><string>monospace</string></test>'
    echo '    <edit name="family" mode="prepend" binding="strong">'
    echo "      <string>$(escape_xml "$MONO")</string>"
    echo '    </edit>'
    echo '  </match>'
    echo ''
  fi

  echo '  <!-- Rendering options -->'
  echo '  <match target="font">'

  # Emit edits only if set by user (so you can generate minimal configs)
  if [[ -n "$ANTIALIAS" ]]; then
    echo "    <edit name=\"antialias\"      mode=\"assign\">  <bool>$ANTIALIAS</bool>         </edit>"
  fi
  if [[ -n "$AUTOHINT" ]]; then
    echo "    <edit name=\"autohint\"       mode=\"assign\">  <bool>$AUTOHINT</bool>        </edit>"
  fi
  if [[ -n "$DPI" ]]; then
    echo "    <edit name=\"dpi\"            mode=\"assign\">  <double>$DPI</double>       </edit>"
  fi
  if [[ -n "$EMBEDDEDBITMAP" ]]; then
    echo "    <edit name=\"embeddedbitmap\" mode=\"assign\">  <bool>$EMBEDDEDBITMAP</bool>         </edit>"
  fi
  if [[ -n "$HINTING" ]]; then
    echo "    <edit name=\"hinting\"        mode=\"assign\">  <bool>$HINTING</bool>         </edit>"
  fi
  if [[ -n "$HINTSTYLE" ]]; then
    echo "    <edit name=\"hintstyle\"      mode=\"assign\">  <const>$HINTSTYLE</const> </edit>"
  fi
  if [[ -n "$LCDFILTER" ]]; then
    echo "    <edit name=\"lcdfilter\"      mode=\"assign\">  <const>lcd$LCDFILTER</const> </edit>"
  fi
  if [[ -n "$RGBA" ]]; then
    echo "    <edit name=\"rgba\"           mode=\"assign\">  <const>$RGBA</const>        </edit>"
  fi

  echo '  </match>'
  echo ''
  echo '</fontconfig>'
} > "$tmp"

mv "$tmp" "$out"
echo "Wrote: $out"
