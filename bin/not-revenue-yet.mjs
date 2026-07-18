#!/usr/bin/env node
import { readFile } from "node:fs/promises";
import { analyzeOpportunity, analyzePortfolio, formatMarkdown } from "../core/analyze.mjs";
import { fetchGithubOpportunity } from "../core/github.mjs";
import { summarizeLedger } from "../core/ledger.mjs";
import { DEMO_OPPORTUNITIES } from "../fixtures/demo-opportunities.mjs";

const [command = "help", target, ...rest] = process.argv.slice(2);
const flags = parseFlags(rest);

try {
  if (command === "vet") {
    if (!target) throw new Error("Usage: not-revenue-yet vet <github-issue-url> [--amount 500] [--funding promised]");
    const input = target.startsWith("http")
      ? await fetchGithubOpportunity(target, { amountUsd: flags.amount, funding: flags.funding, provider: flags.provider, claimers: flags.claimers })
      : JSON.parse(await readFile(target, "utf8"));
    print(analyzeOpportunity(input), flags.format);
  } else if (command === "demo") {
    const portfolio = analyzePortfolio(DEMO_OPPORTUNITIES, new Date("2026-07-18T18:00:00Z"));
    if (flags.format === "json") console.log(JSON.stringify(portfolio, null, 2));
    else {
      console.log(`Advertised: $${portfolio.advertisedUsd.toLocaleString()} | Pipeline: $${portfolio.pipelineUsd.toLocaleString()} | Settled: $${portfolio.settledUsd.toLocaleString()}`);
      for (const item of portfolio.opportunities) console.log(`${item.verdict.padEnd(6)} ${String(item.score).padStart(3)}/100  $${item.amountUsd.toLocaleString().padStart(9)}  ${item.id}`);
    }
  } else if (command === "score") {
    if (!target) throw new Error("Usage: not-revenue-yet score <opportunity.json>");
    print(analyzeOpportunity(JSON.parse(await readFile(target, "utf8"))), flags.format);
  } else if (command === "ledger") {
    if (!target) throw new Error("Usage: not-revenue-yet ledger <events.json|events.jsonl>");
    const content = await readFile(target, "utf8");
    const events = content.trim().startsWith("[") ? JSON.parse(content) : content.trim().split("\n").filter(Boolean).map((line) => JSON.parse(line));
    const summary = summarizeLedger(events, flags.currency || "USD");
    if (flags.format === "json") console.log(JSON.stringify(summary, null, 2));
    else console.log(`${summary.currency} settled: ${(summary.settledMinor / 100).toLocaleString("en-US", { style: "currency", currency: summary.currency })} · pipeline events: ${summary.pipelineEvents} · ignored: ${summary.ignored.length}`);
  } else {
    console.log(`not-revenue-yet\n\nCommands:\n  vet <github-issue-url>   Fetch live evidence and score\n  score <file.json>        Score an evidence contract\n  ledger <events.jsonl>    Count settled net revenue\n  demo                     Show the included false-positive audit\n\nFlags:\n  --amount <usd>\n  --funding <escrowed|promised|unknown>\n  --provider <name>\n  --claimers <count>\n  --currency <ISO code>\n  --format <terminal|json|markdown>`);
  }
} catch (error) {
  console.error(`Error: ${error.message}`);
  process.exitCode = 1;
}

function parseFlags(args) {
  const result = { format: "terminal" };
  for (let index = 0; index < args.length; index += 2) result[args[index].replace(/^--/, "")] = args[index + 1];
  return result;
}

function print(report, format = "terminal") {
  if (format === "json") return console.log(JSON.stringify(report, null, 2));
  if (format === "markdown") return console.log(formatMarkdown(report));
  console.log(`${report.verdict} · ${report.score}/100 · $${report.amountUsd.toLocaleString()} advertised · $${report.countedRevenueUsd.toLocaleString()} settled`);
  console.log(report.title);
  for (const signal of report.signals) console.log(`  ${String(signal.delta).padStart(4)}  ${signal.title}: ${signal.detail}`);
  console.log(`Next: ${report.nextAction}`);
}
