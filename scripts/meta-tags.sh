#!/bin/bash
# Meta tag generator for SEO
# Usage: meta-tags.sh "Page Title" "primary keyword" [./content.md]

set -e

TITLE="$1"
KEYWORD="$2"
FILE="$3"

if [[ -z "$TITLE" || -z "$KEYWORD" ]]; then
  echo "Usage: meta-tags.sh \"Page Title\" \"primary keyword\" [./content.md]"
  exit 1
fi

# Extract content summary if file provided
SUMMARY=""
if [[ -n "$FILE" && -f "$FILE" ]]; then
  # Get first paragraph (skip title)
  SUMMARY=$(cat "$FILE" | sed '/^#/d' | tr '\n' ' ' | sed 's/  */ /g' | cut -c1-300)
fi

# Title tag (50-60 chars optimal)
TITLE_LEN=${#TITLE}
if [[ $TITLE_LEN -gt 60 ]]; then
  TITLE_TAG="${TITLE:0:57}..."
else
  TITLE_TAG="$TITLE"
fi

# Generate description (150-160 chars)
if [[ -n "$SUMMARY" ]]; then
  # Use content summary, ensure keyword included
  if echo "$SUMMARY" | grep -qi "$KEYWORD"; then
    DESC="${SUMMARY:0:157}..."
  else
    DESC="$KEYWORD: ${SUMMARY:0:140}..."
  fi
else
  # Generate generic description
  DESC="Discover $KEYWORD. Comprehensive guide with practical tips, tools, and strategies. Updated for 2026."
fi

# Ensure description length
DESC_LEN=${#DESC}
if [[ $DESC_LEN -gt 160 ]]; then
  DESC="${DESC:0:157}..."
fi

echo "🏷️  Meta Tags Generated"
echo "======================"
echo ""
echo "## HTML Meta Tags"
echo ""
echo "\`\`\`html"
echo "<title>$TITLE_TAG</title>"
echo "<meta name=\"description\" content=\"$DESC\">"
echo "<meta name=\"keywords\" content=\"$KEYWORD\">"
echo "\`\`\`"
echo ""
echo "## Open Graph Tags"
echo ""
echo "\`\`\`html"
echo "<meta property=\"og:title\" content=\"$TITLE_TAG\">"
echo "<meta property=\"og:description\" content=\"$DESC\">"
echo "<meta property=\"og:type\" content=\"article\">"
echo "\`\`\`"
echo ""
echo "## Twitter Card Tags"
echo ""
echo "\`\`\`html"
echo "<meta name=\"twitter:card\" content=\"summary_large_image\">"
echo "<meta name=\"twitter:title\" content=\"$TITLE_TAG\">"
echo "<meta name=\"twitter:description\" content=\"$DESC\">"
echo "\`\`\`"
echo ""
echo "## Stats"
echo "- Title length: $TITLE_LEN chars (target: 50-60)"
echo "- Description length: $DESC_LEN chars (target: 150-160)"
echo "- Primary keyword: $KEYWORD"
