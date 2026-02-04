#!/bin/bash
# Competitor analysis tool - analyzes top ranking pages for a keyword
# Usage: competitor-analysis.sh "target keyword"

set -e

KEYWORD="$1"

if [[ -z "$KEYWORD" ]]; then
  echo "Usage: competitor-analysis.sh \"target keyword\""
  exit 1
fi

ENCODED=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$KEYWORD'))")

echo "🔍 Competitor Analysis: $KEYWORD"
echo "================================"
echo ""

# Fetch search results
TMPFILE=$(mktemp)
curl -s -A "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" \
  "https://html.duckduckgo.com/html/?q=$ENCODED" > "$TMPFILE" 2>/dev/null

# Parse and analyze
python3 - "$TMPFILE" "$KEYWORD" << 'PYEOF'
import sys
import re
from html.parser import HTMLParser
from collections import Counter

with open(sys.argv[1], 'r', encoding='utf-8', errors='ignore') as f:
    html = f.read()

keyword = sys.argv[2].lower()

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
    print("No results found.")
    sys.exit(0)

# Analyze patterns
all_titles = ' '.join(r['title'] for r in results).lower()
all_snippets = ' '.join(r['snippet'] for r in results).lower()

# Common words in titles (excluding stopwords)
stopwords = {'the', 'a', 'an', 'is', 'are', 'and', 'or', 'for', 'to', 'in', 'of', 'with', 'on', 'by', 'at', 'from', 'your', 'you', 'how', 'best', 'top', 'this', 'that', 'what'}
title_words = [w for w in re.findall(r'\b\w{3,}\b', all_titles) if w not in stopwords]
word_freq = Counter(title_words).most_common(10)

# Title patterns
title_patterns = []
if any('how to' in r['title'].lower() for r in results):
    title_patterns.append('How-to guides')
if any(re.search(r'\d+', r['title']) for r in results):
    title_patterns.append('Listicles with numbers')
if any('best' in r['title'].lower() for r in results):
    title_patterns.append('"Best" comparisons')
if any('free' in r['title'].lower() for r in results):
    title_patterns.append('"Free" offerings')
if any('2026' in r['title'] or '2025' in r['title'] for r in results):
    title_patterns.append('Year-dated content')

# Content signals
print("## Top 5 Competitors\n")
for i, r in enumerate(results[:5], 1):
    title = r['title'][:60] + '...' if len(r['title']) > 60 else r['title']
    has_keyword = '✅' if keyword in r['title'].lower() else '❌'
    print(f"{i}. {title}")
    print(f"   Keyword in title: {has_keyword}")
    print()

print("## Content Patterns\n")
if title_patterns:
    print("**Winning title formats:**")
    for p in title_patterns:
        print(f"  - {p}")
    print()

print("**Most used words in titles:**")
for word, count in word_freq[:7]:
    print(f"  - \"{word}\" ({count}x)")
print()

# Recommendations
print("## Recommendations\n")
print("Based on competitor analysis:\n")

if 'how to' in all_titles:
    print("1. **Use How-to format** - Competitors are ranking with tutorials")
if any('free' in r['title'].lower() for r in results):
    print("2. **Mention 'free' if applicable** - Users searching for free solutions")
if word_freq:
    print(f"3. **Include key terms** - Consider using: {', '.join(w[0] for w in word_freq[:5])}")

# Gap analysis
kw_in_title = sum(1 for r in results if keyword in r['title'].lower())
print(f"\n**Keyword presence:** {kw_in_title}/10 competitors have exact keyword in title")
if kw_in_title < 5:
    print("  → Opportunity: Less competition for exact-match titles")
else:
    print("  → Competitive: Most pages optimized for this keyword")
PYEOF

rm -f "$TMPFILE"

echo ""
echo "## Price: 0.35 USDC (via x402)"
