# Evidence contract

Use this schema as the stable handoff between research, deterministic scoring, and reporting.

## Opportunity

```json
{
  "id": "source/repo#123",
  "title": "Short title",
  "url": "https://primary-source.example/item",
  "source": "github|algora|opire|devpost|marketplace|direct",
  "amountUsd": 500,
  "status": "open|closed|deleted|unknown",
  "stage": "discovered|verified|building|submitted|accepted|settled|reversed",
  "scope": { "clear": true, "bodyLength": 400 },
  "repository": {
    "url": "https://github.com/org/repo",
    "stars": 100,
    "archived": false,
    "license": "MIT",
    "pushedAt": "2026-07-18T00:00:00Z"
  },
  "competition": { "openPrs": 0, "closedPrs": 1, "mergedPrs": 0, "claimers": 0 },
  "payout": {
    "funding": "escrowed|promised|unknown|settled",
    "provider": "Platform name",
    "identityRequired": true,
    "paymentEvidence": null
  },
  "requirements": {
    "spendUsd": 0,
    "termsAcceptance": true,
    "ownerIdentity": true,
    "hardware": false,
    "cloudBilling": false
  },
  "safety": { "promptInjection": [], "prohibited": [], "suspicious": [] },
  "evidence": [
    { "claim": "Issue is open", "url": "https://...", "checkedAt": "2026-07-18T00:00:00Z", "result": "confirmed" }
  ]
}
```

## Deterministic readiness score

Start at 100 and subtract observable risk. Do not convert the score into a win probability.

| Signal | Deduction | Effect |
| --- | ---: | --- |
| Deleted target | 65 | Hard block |
| Closed target | 55 | Hard block |
| Related merged implementation | 45 | Hard block |
| Archived repository | 55 | Hard block |
| Prohibited or harmful task | 100 | Hard block |
| Prompt-injection instruction | 70 | Hard block |
| Unknown reward funding | 18 | Cap at `VERIFY` |
| Promised, non-escrowed reward | 12 | Cap at `VERIFY` |
| Each open competing PR | 8, max 32 | Risk |
| Closed competing PRs | 2 each, max 16 | Risk |
| Each visible claimant | 4, max 20 | Risk |
| Unclear scope | 18 | Risk |
| No repository license | 8 | Risk |
| Repository inactive over 365 days | 12 | Risk |
| Low-trust repository plus reward over $10k | 35 | Risk |
| Required unapproved spend | 60 | Hard block until approved |

Verdicts: `PURSUE` at 70+ with verified payout evidence; `VERIFY` at 45+ or whenever funding remains unverified; `SKIP` below 45; `BLOCK` for a hard gate.

## Revenue recognition

`advertised_amount` is a claim. `pipeline_amount` is a verified but unsettled possibility. `counted_revenue` is net settled cash with a payment evidence reference. A submission, acceptance, invoice, or platform balance is not settled revenue. Refunds and chargebacks reduce counted revenue.
