#!/usr/bin/env node
/**
 * x402 SEO Service Server
 * Demonstrates pay-per-use SEO analysis with USDC micropayments
 * 
 * Protocol: HTTP 402 Payment Required
 * Chain: Base Sepolia (testnet)
 * Token: USDC
 */

const http = require('http');
const { execSync } = require('child_process');
const path = require('path');

// Configuration
const PORT = process.env.PORT || 3402;
const PAYEE_ADDRESS = process.env.PAYEE_ADDRESS || '0x5PYRL3zYBJrEPcJdqZziDUP7YyY6XPxRNFNWgTFN39fV';
const BASE_SEPOLIA_CHAIN_ID = 84532;
const USDC_BASE_SEPOLIA = '0x036CbD53842c5426634e7929541eC2318f3dCF7e';

// Service pricing (in USDC, 6 decimals)
const PRICES = {
  keywords: 100000,    // 0.10 USDC
  serp: 250000,        // 0.25 USDC
  score: 150000,       // 0.15 USDC
  meta: 50000,         // 0.05 USDC
};

const scriptsDir = path.dirname(__filename);

// Verify payment proof (simplified - production would verify on-chain)
function verifyPayment(proof, expectedAmount) {
  if (!proof) return false;
  try {
    const { txHash, amount, chain } = JSON.parse(proof);
    // In production: verify tx on-chain via RPC
    return txHash && amount >= expectedAmount && chain === BASE_SEPOLIA_CHAIN_ID;
  } catch {
    return false;
  }
}

// Generate 402 response with payment instructions
function paymentRequired(res, service, amount) {
  const amountStr = (amount / 1000000).toFixed(2);
  res.writeHead(402, {
    'Content-Type': 'application/json',
    'X-Payment': JSON.stringify({
      version: '1.0',
      chain: BASE_SEPOLIA_CHAIN_ID,
      token: USDC_BASE_SEPOLIA,
      payee: PAYEE_ADDRESS,
      amount: amount,
      memo: `SEO service: ${service}`,
    }),
  });
  res.end(JSON.stringify({
    error: 'Payment Required',
    service,
    price: `${amountStr} USDC`,
    instructions: `Pay ${amountStr} USDC to ${PAYEE_ADDRESS} on Base Sepolia, then retry with X-Payment-Proof header`,
  }));
}

// Execute SEO analysis
function runAnalysis(service, query) {
  try {
    switch (service) {
      case 'keywords':
        return execSync(`bash ${scriptsDir}/keywords.sh "${query}"`, { encoding: 'utf8' });
      case 'serp':
        return execSync(`bash ${scriptsDir}/serp-analyze.sh "${query}"`, { encoding: 'utf8' });
      case 'meta':
        const [title, keyword] = query.split('|');
        return execSync(`bash ${scriptsDir}/meta-tags.sh "${title}" "${keyword}"`, { encoding: 'utf8' });
      default:
        return 'Service not found';
    }
  } catch (e) {
    return `Error: ${e.message}`;
  }
}

const server = http.createServer((req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  const service = url.pathname.slice(1); // /keywords -> keywords
  const query = url.searchParams.get('q') || '';
  
  if (!PRICES[service]) {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Unknown service', available: Object.keys(PRICES) }));
    return;
  }
  
  const paymentProof = req.headers['x-payment-proof'];
  
  if (!verifyPayment(paymentProof, PRICES[service])) {
    paymentRequired(res, service, PRICES[service]);
    return;
  }
  
  // Payment verified - run analysis
  const result = runAnalysis(service, query);
  
  res.writeHead(200, { 'Content-Type': 'text/plain' });
  res.end(result);
});

server.listen(PORT, () => {
  console.log(`🔍 SEO x402 Service running on http://localhost:${PORT}`);
  console.log(`\nEndpoints:`);
  console.log(`  GET /keywords?q=<query>  - Keyword research (0.10 USDC)`);
  console.log(`  GET /serp?q=<query>      - SERP analysis (0.25 USDC)`);
  console.log(`  GET /meta?q=<title|keyword> - Meta tags (0.05 USDC)`);
  console.log(`\nPayee: ${PAYEE_ADDRESS}`);
  console.log(`Chain: Base Sepolia (${BASE_SEPOLIA_CHAIN_ID})`);
});
