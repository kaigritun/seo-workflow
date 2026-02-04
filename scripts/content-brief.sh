#!/bin/bash
# AI-powered content brief generator
# Usage: content-brief.sh "target keyword"

set -e

KEYWORD="$1"

if [[ -z "$KEYWORD" ]]; then
  echo "Usage: content-brief.sh \"target keyword\""
  exit 1
fi

echo "📝 Content Brief: $KEYWORD"
echo "=========================="
echo ""

# Get keyword suggestions first
ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$KEYWORD'))")

# Fetch related keywords
SUGGESTIONS=$(curl -s "https://suggestqueries.google.com/complete/search?client=firefox&q=$ENCODED" | \
  python3 -c "import sys,json; data=json.load(sys.stdin); print('\n'.join(data[1][:8]))" 2>/dev/null || echo "")

# Fetch "questions" related
QUESTIONS=$(curl -s "https://suggestqueries.google.com/complete/search?client=firefox&q=how+to+$ENCODED" | \
  python3 -c "import sys,json; data=json.load(sys.stdin); print('\n'.join(data[1][:5]))" 2>/dev/null || echo "")

WHAT_QUESTIONS=$(curl -s "https://suggestqueries.google.com/complete/search?client=firefox&q=what+is+$ENCODED" | \
  python3 -c "import sys,json; data=json.load(sys.stdin); print('\n'.join(data[1][:3]))" 2>/dev/null || echo "")

# Generate content brief
echo "## Target Keyword"
echo "**Primary:** $KEYWORD"
echo ""

echo "## Related Keywords to Include"
if [[ -n "$SUGGESTIONS" ]]; then
  echo "$SUGGESTIONS" | while read -r kw; do
    [[ -n "$kw" ]] && echo "  - $kw"
  done
else
  echo "  (No suggestions found)"
fi
echo ""

echo "## Questions to Answer"
if [[ -n "$QUESTIONS" ]]; then
  echo "**How-to questions:**"
  echo "$QUESTIONS" | while read -r q; do
    [[ -n "$q" ]] && echo "  - $q"
  done
fi
if [[ -n "$WHAT_QUESTIONS" ]]; then
  echo "**What-is questions:**"
  echo "$WHAT_QUESTIONS" | while read -r q; do
    [[ -n "$q" ]] && echo "  - $q"
  done
fi
echo ""

echo "## Recommended Structure"
echo ""
echo "### Title (50-60 chars)"
echo "Include \"$KEYWORD\" near the beginning"
echo ""
echo "### Introduction (100-150 words)"
echo "- Hook with problem/benefit"
echo "- Include primary keyword in first paragraph"
echo "- Preview what reader will learn"
echo ""
echo "### Main Sections (H2s)"
echo "1. What is [topic] / Overview"
echo "2. Why [topic] matters / Benefits"
echo "3. How to [do topic] / Step-by-step"
echo "4. Best [tools/practices] for [topic]"
echo "5. Common mistakes / FAQs"
echo ""
echo "### Conclusion"
echo "- Summarize key points"
echo "- Call to action"
echo "- Link to related content"
echo ""

echo "## Content Specifications"
echo ""
echo "**Target word count:** 1,500-2,500 words"
echo "**Keyword density:** 1-2%"
echo "**Heading structure:** 1 H1, 4-6 H2s, 2-4 H3s per section"
echo "**Internal links:** 3-5 to related content"
echo "**External links:** 2-3 to authoritative sources"
echo "**Images:** 3-5 with alt text containing keyword variations"
echo ""

echo "## SEO Checklist"
echo "- [ ] Primary keyword in title"
echo "- [ ] Primary keyword in H1"
echo "- [ ] Primary keyword in first 100 words"
echo "- [ ] Related keywords throughout body"
echo "- [ ] Meta description (150-160 chars)"
echo "- [ ] URL contains primary keyword"
echo "- [ ] Alt text on all images"
echo "- [ ] Internal links to related pages"
echo ""
echo "## Price: 0.50 USDC (via x402)"
