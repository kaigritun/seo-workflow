---
name: seo-workflow
description: SEO-as-a-service skill with x402 USDC micropayments. Agents pay per analysis - keyword research, SERP analysis, content scoring, meta tag generation. Uses Circle x402 HTTP payment protocol for trustless agent-to-agent SEO services.
---

# SEO Workflow

End-to-end SEO toolkit with USDC micropayments via x402 protocol.

## USDC Integration (x402)

This skill supports pay-per-use SEO analysis via the x402 HTTP payment protocol:

| Service | Price |
|---------|-------|
| Keyword research | 0.10 USDC |
| SERP analysis | 0.25 USDC |
| Content scoring | 0.15 USDC |
| Meta tag generation | 0.05 USDC |

When another agent calls a service endpoint, they receive HTTP 402 with payment instructions. After USDC payment on Base, the endpoint returns premium analysis.

**Why USDC for SEO?**
- Agents can monetize SEO expertise autonomously
- Pay only for analysis you need (no subscriptions)
- Trustless settlement on Base
- Micropayments make single queries economical

## Quick Commands

```bash
# Keyword suggestions (free, uses Google autocomplete)
{baseDir}/scripts/keywords.sh "ai resume builder"

# Analyze SERP competition
{baseDir}/scripts/serp-analyze.sh "best ai tools for job search"

# Score content optimization
{baseDir}/scripts/content-score.sh ./article.md "target keyword"

# Generate meta tags
{baseDir}/scripts/meta-tags.sh "Page Title" "Primary keyword" ./content.md
```

## Workflow

### 1. Keyword Research

Start with seed keyword, expand with suggestions:

```bash
{baseDir}/scripts/keywords.sh "freelance ai tools" --depth 2
```

Output: Related keywords with relative search interest.

### 2. SERP Analysis

Before writing, understand what ranks:

```bash
{baseDir}/scripts/serp-analyze.sh "how to use ai for freelancing"
```

Output: Top 10 results with titles, descriptions, word counts, common themes.

### 3. Content Optimization

Score existing content against target keyword:

```bash
{baseDir}/scripts/content-score.sh ./draft.md "ai freelancing tools"
```

Checks:
- Keyword in title, H1, first 100 words
- Keyword density (target: 1-2%)
- Heading structure (H2/H3 usage)
- Internal/external links
- Content length vs SERP average

### 4. Meta Tag Generation

Generate optimized title + description:

```bash
{baseDir}/scripts/meta-tags.sh "AI Tools for Freelancers" "ai freelancing" ./article.md
```

Output: Title tag (50-60 chars), meta description (150-160 chars), OG tags.

## Best Practices

- **One primary keyword per page** - Don't dilute focus
- **Search intent match** - Informational vs transactional vs navigational
- **Content depth** - Match or exceed competitor word count
- **Fresh content** - Update dates, add recent examples
- **Internal linking** - 3-5 relevant internal links per article

## x402 Server (Agent-to-Agent Commerce)

Run a paid SEO service for other agents:

```bash
# Start x402 server (requires PAYEE_ADDRESS env var)
PAYEE_ADDRESS=0xYourWallet node {baseDir}/scripts/x402-server.js
```

**Client usage (from another agent):**
```bash
# First call returns 402 with payment instructions
curl http://seo-service.example:3402/keywords?q=ai+tools
# -> HTTP 402, X-Payment header with USDC payment details

# After paying USDC on Base, retry with proof
curl -H "X-Payment-Proof: {\"txHash\":\"0x...\",\"amount\":100000,\"chain\":84532}" \
  http://seo-service.example:3402/keywords?q=ai+tools
# -> Keyword analysis results
```

**Available endpoints:**
- `GET /keywords?q=<query>` - Keyword suggestions (0.10 USDC)
- `GET /serp?q=<query>` - SERP analysis (0.25 USDC)
- `GET /meta?q=<title|keyword>` - Meta tag generation (0.05 USDC)

## Integration

Works with Google Search Console skill (`gsc`) for:
- Tracking indexed pages
- Monitoring search performance
- Identifying ranking opportunities

## GitHub

Source: https://github.com/kaigritun/seo-workflow
