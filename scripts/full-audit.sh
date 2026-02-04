#!/bin/bash
# Full SEO Audit - Comprehensive analysis combining all tools
# Usage: full-audit.sh "target keyword" [url]

set -e

KEYWORD="$1"
URL="$2"

SCRIPTS_DIR="$(dirname "$0")"

if [[ -z "$KEYWORD" ]]; then
  echo "Usage: full-audit.sh \"target keyword\" [url]"
  exit 1
fi

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║            🔍 COMPREHENSIVE SEO AUDIT                        ║"
echo "║            Target: $KEYWORD"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Running full analysis suite. This may take 30-60 seconds..."
echo ""

# 1. Keyword Research
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 SECTION 1: KEYWORD RESEARCH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPTS_DIR/keywords.sh" "$KEYWORD" 2>/dev/null || echo "Keyword research failed"
echo ""

# 2. SERP Analysis
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔎 SECTION 2: SERP ANALYSIS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPTS_DIR/serp-analyze.sh" "$KEYWORD" 2>/dev/null || echo "SERP analysis failed"
echo ""

# 3. Competitor Analysis
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🏆 SECTION 3: COMPETITOR ANALYSIS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPTS_DIR/competitor-analysis.sh" "$KEYWORD" 2>/dev/null || echo "Competitor analysis failed"
echo ""

# 4. Content Brief
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 SECTION 4: CONTENT BRIEF"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
bash "$SCRIPTS_DIR/content-brief.sh" "$KEYWORD" 2>/dev/null || echo "Content brief failed"
echo ""

# 5. Meta Tags
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🏷️ SECTION 5: RECOMMENDED META TAGS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
# Generate a smart title based on keyword
TITLE="$KEYWORD - Complete Guide $(date +%Y)"
bash "$SCRIPTS_DIR/meta-tags.sh" "$TITLE" "$KEYWORD" 2>/dev/null || echo "Meta tag generation failed"
echo ""

# Summary
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    📋 AUDIT SUMMARY                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Keyword analyzed: $KEYWORD"
echo "Audit completed: $(date)"
echo ""
echo "Next steps:"
echo "  1. Use keyword suggestions for content expansion"
echo "  2. Follow competitor patterns that are working"
echo "  3. Use content brief structure for new articles"
echo "  4. Apply recommended meta tags"
echo "  5. Score content after writing with content-score.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💰 Full Audit Price: 1.00 USDC (via x402)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
