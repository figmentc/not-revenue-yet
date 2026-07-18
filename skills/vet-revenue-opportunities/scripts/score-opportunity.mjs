#!/usr/bin/env node
import { readFile } from "node:fs/promises";
import { analyzeOpportunity, formatMarkdown } from "../../../core/analyze.mjs";

const path = process.argv[2];
if (!path) {
  console.error("Usage: node scripts/score-opportunity.mjs opportunity.json");
  process.exit(1);
}
const report = analyzeOpportunity(JSON.parse(await readFile(path, "utf8")));
console.log(formatMarkdown(report));
