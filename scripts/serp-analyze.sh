#!/bin/bash
# SERP analysis tool - analyzes search results for a keyword
# Usage: serp-analyze.sh "target keyword"

set -e

KEYWORD="$1"

if [[ -z "$KEYWORD" ]]; then
  echo "Usage: serp-analyze.sh \"target keyword\""
  exit 1
fi

ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$KEYWORD'))")

echo "🔍 SERP Analysis: $KEYWORD"
echo "=========================="
echo ""

# Use DuckDuckGo HTML (more scraper-friendly than Google)
TMPFILE=$(mktemp)
curl -s -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
  "https://html.duckduckgo.com/html/?q=$ENCODED" > "$TMPFILE" 2>/dev/null

if [[ ! -s "$TMPFILE" ]]; then
  echo "❌ Could not fetch search results"
  rm -f "$TMPFILE"
  exit 1
fi

# Parse results using Python for reliability
python3 - "$TMPFILE" << 'PYEOF'
import sys
from html.parser import HTMLParser
import re

with open(sys.argv[1], 'r', encoding='utf-8', errors='ignore') as f:
    html = f.read()

class DDGParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.results = []
        self.current = {}
        self.in_title = False
        self.in_snippet = False
        
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == 'a' and 'result__a' in attrs.get('class', ''):
            self.in_title = True
            self.current = {'url': attrs.get('href', ''), 'title': '', 'snippet': ''}
        elif tag == 'a' and 'result__snippet' in attrs.get('class', ''):
            self.in_snippet = True
            
    def handle_endtag(self, tag):
        if tag == 'a':
            if self.in_title:
                self.in_title = False
            if self.in_snippet:
                self.in_snippet = False
                if self.current:
                    self.results.append(self.current)
                    self.current = {}
                    
    def handle_data(self, data):
        if self.in_title and self.current:
            self.current['title'] += data.strip()
        elif self.in_snippet and self.current:
            self.current['snippet'] += data.strip()

parser = DDGParser()
try:
    parser.feed(html)
except:
    pass

results = parser.results[:10]

if not results:
    print("No results found or parsing failed.")
    print("Tip: Use browser automation for more reliable SERP data.")
    sys.exit(0)

print(f"## Top {len(results)} Results\n")

title_lengths = []
desc_lengths = []
common_words = {}

for i, r in enumerate(results, 1):
    title = r['title'][:70] + '...' if len(r['title']) > 70 else r['title']
    snippet = r['snippet'][:150] + '...' if len(r['snippet']) > 150 else r['snippet']
    
    print(f"### {i}. {title}")
    print(f"**URL:** {r['url'][:80]}")
    print(f"**Snippet:** {snippet}")
    print()
    
    title_lengths.append(len(r['title']))
    desc_lengths.append(len(r['snippet']))
    
    # Track common words
    words = re.findall(r'\b\w{4,}\b', r['title'].lower())
    for w in words:
        common_words[w] = common_words.get(w, 0) + 1

print("## Analysis")
print()
if title_lengths:
    print(f"- **Avg title length:** {sum(title_lengths)//len(title_lengths)} chars")
if desc_lengths:
    print(f"- **Avg description length:** {sum(desc_lengths)//len(desc_lengths)} chars")

# Top common words in titles
top_words = sorted(common_words.items(), key=lambda x: -x[1])[:5]
if top_words:
    print(f"- **Common title words:** {', '.join(w[0] for w in top_words)}")

print()
print("## Recommendations")
print("- Match or exceed competitor content depth")
print("- Include common title words naturally")
print("- Study top 3 results for content structure")
PYEOF

rm -f "$TMPFILE"
