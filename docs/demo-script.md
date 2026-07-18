# Demo script — target 2:20

## 0:00–0:18 — The problem

Open the hero.

> “I asked an autonomous agent to make $10,000. In minutes it found four live-looking paid issues advertising more than $1.1 million. But a listing is a claim. Cash is a fact.”

Scroll to the three totals.

> “Not Revenue Yet separates advertised value, plausible pipeline, and settled revenue. Right now, settled is honestly zero.”

## 0:18–0:58 — Reality gate

Open the Gitea case.

> “This $1,880 listing looks legitimate: real platform, famous repository, detailed issue. The canonical issue is closed, the implementation was merged in March, and ten duplicate attempts were rejected. The plugin hard-blocks it before the agent wastes days.”

Open ZeroPerl.

> “The $1,500 target is even worse: the issue was deleted after the feature merged in 2025. The aggregator still advertises it.”

## 0:58–1:20 — Adversarial economics

Open `c1work`.

> “A near-empty repository advertised $1.16 million for nineteen characters of scope. Not Revenue Yet never calls that a million dollars of pipeline. It deducts for unknown funding, unclear acceptance criteria, missing license, and reward-to-trust mismatch.”

## 1:20–1:46 — Live and installable

Use the live form or show the CLI:

```bash
node bin/not-revenue-yet.mjs vet \
  https://github.com/go-gitea/gitea/issues/24635 \
  --amount 1880 --funding promised
```

> “The browser and CLI import the same scoring core. The Codex skill adds official platform rules, owner authority, and the safest next action.”

## 1:46–2:08 — Settlement invariant

Scroll to the stage rail.

> “Discovered, verified, built, submitted, and accepted all count as zero revenue. Only a settled event with payment evidence is counted. Duplicate receipts are ignored; refunds and chargebacks reverse the total.”

Show:

```bash
node bin/not-revenue-yet.mjs ledger fixtures/ledger-demo.jsonl
```

Expected: `$0.00` despite a $15,000 promise, approval, and pending payment.

## 2:08–2:20 — Close

Return to the hero.

> “Not Revenue Yet lets Codex keep moving through safe, reversible work—without confusing motion with money or access with authority. Proof before pursuit. Settlement before success.”
