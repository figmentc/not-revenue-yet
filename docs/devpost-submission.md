# OpenAI Build Week submission draft

## Project

**Name:** Not Revenue Yet  
**Track:** Developer Tools  
**Tagline:** A proof-first Codex plugin that vets paid opportunities, guards owner authority, and counts money only after settlement.

**Demo:** https://not-revenue-yet.austinhan.chatgpt.site  
**Repository:** https://github.com/figmentc/not-revenue-yet  
**Video:** `[ADD PUBLIC YOUTUBE URL]`  
**Local video:** `artifacts/not-revenue-yet-build-week-demo.mp4`
**Gallery image:** `assets/not-revenue-yet-hero.jpg`
**Codex session:** `019f745a-b442-7a13-9a06-6f9fb546a908` (core project task; confirm the displayed `/feedback` value before final submission)

## Inspiration

We gave an autonomous coding agent a simple goal: make $10,000 without moving funds unless the owner approved the exact spend. The obvious route was paid GitHub issues. The first public feed advertised more than $1.1 million across only a few listings—but live verification found a deleted issue, a feature already merged, crowded duplicates, and a million-dollar claim attached to a near-empty repository.

The failure was not discovery. It was epistemology: agents are optimized to act on plausible text, while money-making listings are untrusted, time-sensitive claims. We needed a trust compiler between “I found an opportunity” and “I should spend time or money on it.”

## What it does

Not Revenue Yet is an installable Codex plugin, deterministic CLI, and browser evidence lab.

Given a bounty, contest, contract, marketplace listing, or product opportunity, it independently evaluates four gates:

1. **Reality:** Is the canonical work target open, current, licensed, and not already completed?
2. **Payout:** Is the reward escrowed, platform-backed, merely promised, or actually settled?
3. **Authority:** Can the agent safely continue locally, or does the next step require the owner's identity, terms acceptance, or exact spending approval?
4. **Safety:** Does the untrusted listing contain prompt injection, CAPTCHA bypass, credential requests, or harmful work?

It produces `PURSUE`, `VERIFY`, `SKIP`, or `BLOCK`, with timestamped evidence and deterministic deductions. A separate append-only ledger recognizes only net settled payments with an external evidence reference. Promises, submissions, accepted work, invoices, and pending balances remain $0 revenue.

## How we built it

- A pure JavaScript evidence and scoring core shared by the CLI and React/Vite browser app.
- A read-only GitHub adapter that checks canonical issue state, repository health, licensing, and cross-referenced pull requests.
- An installable Codex plugin with a `vet-revenue-opportunities` skill and a stable evidence contract.
- An integer-minor-unit ledger with idempotency keys, refund/chargeback reversals, and no implicit currency conversion.
- Six deterministic tests covering stale work, implausible rewards, prompt injection, settlement recognition, and duplicate payment imports.
- Timestamped real-world fixtures for two stale Opire listings, one implausible listing, and one open-but-competitive issue.

## How Codex and GPT-5.6 helped

Codex and GPT-5.6 performed the end-to-end research and implementation loop: they compared current official platform rules, rejected unsafe listings, used multiple agents to independently verify issue and pull-request history, turned the findings into a normalized evidence model, implemented the scorer/ledger/plugin/UI, ran live GitHub checks, and visually tested the browser experience.

The collaboration was especially valuable when an apparently attractive $1,880 Gitea listing turned out to reference work merged months earlier. A second agent independently traced a $1,500 listing through a repository rename and deleted issue to the original merged implementation. Those were not synthetic edge cases; they became the golden fixtures and product story.

Human-directed decisions remained explicit: no bank access, no fabricated identity, no automated acceptance of legal terms, no payout guarantee, and no revenue recognition before settlement.

## Challenges

- Aggregators and canonical sources can disagree, so canonical repository state must win.
- “Reward amount” and “payout certainty” are different dimensions; a high amount can lower confidence when repository trust is weak.
- Opportunity quality and action authorization must remain separate. A good opportunity can still require an owner-controlled KYC or contract step.
- Live anonymous GitHub API limits make demos fragile, so the app degrades to timestamped evidence snapshots without duplicating scoring logic.

## Accomplishments

- The same deterministic engine powers the installed skill, CLI, tests, and public browser demo.
- The demo converts $1,163,486 of advertised value into $0 settled revenue without inventing probabilities.
- The system keeps reversible zero-cost work autonomous while exact-spend, identity, and settlement gates remain explicit.
- Real false positives became reproducible test fixtures with primary-source links.

## What we learned

Autonomous earning is mostly a verification and accounting problem. Agents do not need another feed of possibilities; they need disciplined source precedence, action-scoped authority, and an honest definition of “done.”

## What's next

- Signed evidence snapshots and hash-linked ledger events.
- Additional read-only adapters for contests, freelance marketplaces, and grant programs.
- Contribution-policy and AI-disclosure checks before pull-request submission.
- Optional owner-approved connectors for payout status—never banking credentials.

## Built with

Codex, GPT-5.6, JavaScript, React, Vinext (Next.js-compatible), Vite, Cloudflare Workers, OpenAI Sites, GitHub REST API, Codex plugins and skills.
