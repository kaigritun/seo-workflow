#!/bin/bash
# Keyword suggestion tool using Google Autocomplete API (free, no key needed)
# Usage: keywords.sh "seed keyword" [--depth N]

set -e

SEED="$1"
DEPTH=1

# Parse args
shift || true
while [[ $# -gt 0 ]]; do
  case $1 in
    --depth) DEPTH="$2"; shift 2 ;;
    *) shift ;;
  esac
done

if [[ -z "$SEED" ]]; then
  echo "Usage: keywords.sh \"seed keyword\" [--depth N]"
  exit 1
fi

get_suggestions() {
  local query="$1"
  local encoded=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$query'))")
  curl -s "https://suggestqueries.google.com/complete/search?client=firefox&q=$encoded" | \
    python3 -c "import sys,json; data=json.load(sys.stdin); print('\n'.join(data[1]))" 2>/dev/null || true
}

echo "🔍 Keyword suggestions for: $SEED"
echo "================================"
echo ""

# Get initial suggestions
SUGGESTIONS=$(get_suggestions "$SEED")
echo "## Primary suggestions"
echo "$SUGGESTIONS" | head -10
echo ""

# Depth 2: expand top suggestions
if [[ "$DEPTH" -ge 2 ]]; then
  echo "## Expanded suggestions"
  echo "$SUGGESTIONS" | head -3 | while read -r kw; do
    if [[ -n "$kw" ]]; then
      echo ""
      echo "### $kw"
      get_suggestions "$kw" | head -5
    fi
  done
fi

# Add modifiers
echo ""
echo "## With common modifiers"
for mod in "best" "how to" "free" "tools" "vs"; do
  result=$(get_suggestions "$mod $SEED" | head -3)
  if [[ -n "$result" ]]; then
    echo ""
    echo "### $mod + $SEED"
    echo "$result"
  fi
done
