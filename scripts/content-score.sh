#!/bin/bash
# Content SEO scoring tool
# Usage: content-score.sh ./article.md "target keyword"

set -e

FILE="$1"
KEYWORD="$2"

if [[ -z "$FILE" || -z "$KEYWORD" ]]; then
  echo "Usage: content-score.sh ./article.md \"target keyword\""
  exit 1
fi

if [[ ! -f "$FILE" ]]; then
  echo "Error: File not found: $FILE"
  exit 1
fi

CONTENT=$(cat "$FILE")
KEYWORD_LOWER=$(echo "$KEYWORD" | tr '[:upper:]' '[:lower:]')

# Word count
WORD_COUNT=$(echo "$CONTENT" | wc -w | tr -d ' ')

# Keyword count (case insensitive)
KEYWORD_COUNT=$(echo "$CONTENT" | tr '[:upper:]' '[:lower:]' | grep -o "$KEYWORD_LOWER" | wc -l | tr -d ' ')

# Keyword density
if [[ $WORD_COUNT -gt 0 ]]; then
  DENSITY=$(echo "scale=2; $KEYWORD_COUNT * 100 / $WORD_COUNT" | bc)
else
  DENSITY=0
fi

# Check title (first H1)
TITLE=$(echo "$CONTENT" | grep -m1 "^# " | sed 's/^# //' || echo "")
TITLE_HAS_KW=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | grep -c "$KEYWORD_LOWER" || echo "0")

# Check first 100 words
FIRST_100=$(echo "$CONTENT" | tr '\n' ' ' | cut -d' ' -f1-100)
FIRST_100_HAS_KW=$(echo "$FIRST_100" | tr '[:upper:]' '[:lower:]' | grep -c "$KEYWORD_LOWER" || echo "0")

# Count headings
H2_COUNT=$(echo "$CONTENT" | grep -c "^## " || echo "0")
H3_COUNT=$(echo "$CONTENT" | grep -c "^### " || echo "0")

# Count links
INTERNAL_LINKS=$(echo "$CONTENT" | grep -oE '\[.*\]\(/[^)]+\)' | wc -l | tr -d ' ')
EXTERNAL_LINKS=$(echo "$CONTENT" | grep -oE '\[.*\]\(https?://[^)]+\)' | wc -l | tr -d ' ')

# Calculate score
SCORE=0
FEEDBACK=""

# Word count (target: 1500+)
if [[ $WORD_COUNT -ge 1500 ]]; then
  SCORE=$((SCORE + 20))
  FEEDBACK+="✅ Word count: $WORD_COUNT (good length)\n"
elif [[ $WORD_COUNT -ge 800 ]]; then
  SCORE=$((SCORE + 10))
  FEEDBACK+="⚠️  Word count: $WORD_COUNT (consider expanding to 1500+)\n"
else
  FEEDBACK+="❌ Word count: $WORD_COUNT (too short, aim for 1500+)\n"
fi

# Keyword in title
if [[ $TITLE_HAS_KW -gt 0 ]]; then
  SCORE=$((SCORE + 20))
  FEEDBACK+="✅ Keyword in title\n"
else
  FEEDBACK+="❌ Keyword missing from title\n"
fi

# Keyword in first 100 words
if [[ $FIRST_100_HAS_KW -gt 0 ]]; then
  SCORE=$((SCORE + 15))
  FEEDBACK+="✅ Keyword in first 100 words\n"
else
  FEEDBACK+="❌ Keyword not in first 100 words\n"
fi

# Keyword density (target: 1-2%)
if (( $(echo "$DENSITY >= 1 && $DENSITY <= 2" | bc -l) )); then
  SCORE=$((SCORE + 15))
  FEEDBACK+="✅ Keyword density: ${DENSITY}% (optimal)\n"
elif (( $(echo "$DENSITY > 0 && $DENSITY < 1" | bc -l) )); then
  SCORE=$((SCORE + 8))
  FEEDBACK+="⚠️  Keyword density: ${DENSITY}% (could use more mentions)\n"
elif (( $(echo "$DENSITY > 2" | bc -l) )); then
  SCORE=$((SCORE + 5))
  FEEDBACK+="⚠️  Keyword density: ${DENSITY}% (may be over-optimized)\n"
else
  FEEDBACK+="❌ Keyword density: ${DENSITY}% (keyword not found)\n"
fi

# Heading structure
if [[ $H2_COUNT -ge 3 ]]; then
  SCORE=$((SCORE + 15))
  FEEDBACK+="✅ Heading structure: $H2_COUNT H2s, $H3_COUNT H3s\n"
elif [[ $H2_COUNT -ge 1 ]]; then
  SCORE=$((SCORE + 8))
  FEEDBACK+="⚠️  Heading structure: $H2_COUNT H2s (add more sections)\n"
else
  FEEDBACK+="❌ No H2 headings found\n"
fi

# Links
if [[ $INTERNAL_LINKS -ge 3 ]]; then
  SCORE=$((SCORE + 10))
  FEEDBACK+="✅ Internal links: $INTERNAL_LINKS\n"
elif [[ $INTERNAL_LINKS -ge 1 ]]; then
  SCORE=$((SCORE + 5))
  FEEDBACK+="⚠️  Internal links: $INTERNAL_LINKS (add 3+)\n"
else
  FEEDBACK+="❌ No internal links\n"
fi

if [[ $EXTERNAL_LINKS -ge 2 ]]; then
  SCORE=$((SCORE + 5))
  FEEDBACK+="✅ External links: $EXTERNAL_LINKS\n"
else
  FEEDBACK+="⚠️  External links: $EXTERNAL_LINKS (consider adding citations)\n"
fi

echo "📊 SEO Content Score: $SCORE/100"
echo "================================"
echo "Target keyword: $KEYWORD"
echo "File: $FILE"
echo ""
echo -e "$FEEDBACK"

# Grade
if [[ $SCORE -ge 80 ]]; then
  echo "Grade: A - Well optimized! 🎉"
elif [[ $SCORE -ge 60 ]]; then
  echo "Grade: B - Good, minor improvements needed"
elif [[ $SCORE -ge 40 ]]; then
  echo "Grade: C - Needs work"
else
  echo "Grade: D - Significant optimization needed"
fi
