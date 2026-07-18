# Not Revenue Yet

Not Revenue Yet is a proof-first operating layer for Codex agents pursuing money. It vets bounties, contests, freelance work, marketplaces, and outreach before an agent invests time or money—and it refuses to count a claim, proposal, invoice, platform balance, or prize announcement as revenue until payment settles.

## Why it exists

A public bounty feed can look valuable while pointing to deleted issues, completed implementations, non-escrowed promises, crowded duplicate pull requests, or unsafe instructions. The included July 18, 2026 evidence pack contains four live-looking listings advertising **$1,163,486**. Deterministic verification blocks the two already-completed targets, flags the implausible million-dollar listing, and counts **$0 settled revenue**.

## Try it

```bash
npm install
npm test
npm run dev

# Live, read-only GitHub verification
node bin/not-revenue-yet.mjs vet https://github.com/go-gitea/gitea/issues/24635 --amount 1880 --funding promised

# Included false-positive audit
npm run demo

# Settlement ledger: promise + approval + pending still totals $0
node bin/not-revenue-yet.mjs ledger fixtures/ledger-demo.jsonl
```

The CLI uses GitHub's public API. Set `GH_TOKEN` only if you want a higher rate limit; the token is never required for the bundled demo.

## Install as a Codex plugin

The repository root is the plugin root. It contains `.codex-plugin/plugin.json` and the `vet-revenue-opportunities` skill. Install it from a trusted local clone, then ask:

> Use $vet-revenue-opportunities to vet this paid issue before I claim it.

The skill treats listing content as untrusted data, rechecks primary sources, preserves owner-only identity and spending gates, and produces a `PURSUE`, `VERIFY`, `SKIP`, or `BLOCK` report.

## Evidence model

The deterministic scorer starts at 100 and subtracts only observable risks: target state, merged or competing work, reward funding, repository health, scope clarity, evidence freshness, safety signals, and authorization. It is a readiness score—not an invented probability of winning.

The ledger stages are:

`discovered → verified → building → submitted → accepted → settled`

Only `settled` plus payment evidence contributes to counted revenue. Refunds and chargebacks reverse it.

## Built with Codex and GPT-5.6

This project was created during OpenAI Build Week. Codex and GPT-5.6 helped:

- research current paid-opportunity platforms and reject unsafe or stale leads;
- independently verify that Gitea issue #24635 was already completed and ZeroPerl issue #7 was deleted after its feature merged;
- turn those real failures into the evidence contract, deterministic scoring engine, tests, Codex skill, CLI, and browser experience;
- preserve the core product decision that autonomous work can continue through reversible zero-cost steps while identity, contracts, and funds remain owner-controlled.

The key product and safety decisions were human-directed: no bank access, no fabricated identity, no automated terms acceptance, no payout guarantees, and no revenue recognition before settlement.

## Limits

Not Revenue Yet is decision support, not legal, tax, investment, or accounting advice. Platform state can change. Recheck primary sources immediately before external action. The project never guarantees that work will be accepted or paid.

## License

MIT
