const STAGES = ["discovered", "verified", "building", "submitted", "accepted", "settled", "reversed"];

const clamp = (value, min, max) => Math.min(max, Math.max(min, value));
const number = (value, fallback = 0) => Number.isFinite(Number(value)) ? Number(value) : fallback;
const daysBetween = (then, now) => then ? Math.max(0, (now.getTime() - new Date(then).getTime()) / 86_400_000) : null;

export function analyzeOpportunity(raw, now = new Date()) {
  const opportunity = normalizeOpportunity(raw);
  const signals = [];
  let score = 100;
  let hardBlock = false;
  let payoutCap = false;

  const add = (code, delta, title, detail, options = {}) => {
    score -= delta;
    hardBlock ||= Boolean(options.hardBlock);
    payoutCap ||= Boolean(options.payoutCap);
    signals.push({ code, delta: -delta, title, detail, severity: options.severity || (options.hardBlock ? "critical" : delta >= 18 ? "high" : "medium"), evidenceUrl: options.evidenceUrl || null });
  };

  if (opportunity.status === "deleted") add("target_deleted", 65, "Target no longer exists", "The referenced work item cannot be reviewed or accepted.", { hardBlock: true, evidenceUrl: opportunity.url });
  if (opportunity.status === "closed") add("target_closed", 55, "Target is closed", "No open acceptance target remains.", { hardBlock: true, evidenceUrl: opportunity.url });
  if (opportunity.competition.mergedPrs > 0) add("implementation_merged", 45, "Implementation already merged", `${opportunity.competition.mergedPrs} related pull request(s) are merged.`, { hardBlock: true });
  if (opportunity.repository.archived) add("repo_archived", 55, "Repository is archived", "Maintainers have made the repository read-only.", { hardBlock: true, evidenceUrl: opportunity.repository.url });

  if (opportunity.safety.prohibited.length) add("prohibited_work", 100, "Unsafe or prohibited task", opportunity.safety.prohibited.join("; "), { hardBlock: true });
  if (opportunity.safety.promptInjection.length) add("prompt_injection", 70, "Untrusted instructions detected", opportunity.safety.promptInjection.join("; "), { hardBlock: true });

  if (opportunity.payout.funding === "unknown") add("funding_unknown", 18, "Reward funding is unverified", "Advertised value is not proof of escrow or payment ability.", { payoutCap: true });
  if (opportunity.payout.funding === "promised") add("funding_promised", 12, "Reward is a promise, not escrow", "The payer may still choose whether and when to pay.", { payoutCap: true });

  const openPenalty = Math.min(32, opportunity.competition.openPrs * 8);
  if (openPenalty) add("open_competition", openPenalty, "Active competing implementations", `${opportunity.competition.openPrs} related pull request(s) are open.`);
  const closedPenalty = Math.min(16, opportunity.competition.closedPrs * 2);
  if (closedPenalty) add("failed_competition", closedPenalty, "Crowded or historically rejected", `${opportunity.competition.closedPrs} related pull request(s) were closed without merge.`);
  const claimerPenalty = Math.min(20, opportunity.competition.claimers * 4);
  if (claimerPenalty) add("visible_claimers", claimerPenalty, "Other claimants are visible", `${opportunity.competition.claimers} contributor(s) already signaled intent.`);

  if (!opportunity.scope.clear || opportunity.scope.bodyLength < 120) add("scope_unclear", 18, "Acceptance criteria are unclear", "Clarify the deliverable and tests before implementation.");
  if (!opportunity.repository.license) add("license_missing", 8, "Repository license not verified", "Contribution and reuse rights need confirmation.");

  const inactivityDays = daysBetween(opportunity.repository.pushedAt, now);
  if (inactivityDays !== null && inactivityDays > 365) add("repo_inactive", 12, "Repository appears inactive", `Last repository push was ${Math.floor(inactivityDays)} days ago.`);

  const lowTrust = opportunity.repository.stars < 5 || opportunity.repository.isBotInstalled === true;
  if (opportunity.amountUsd > 10_000 && lowTrust) add("implausible_reward", 35, "Reward is disproportionate to repository trust", "Verify the payer and funding off-platform before investing work.", { payoutCap: true });

  if (opportunity.requirements.spendUsd > opportunity.authority.approvedSpendUsd) add("spend_unapproved", 60, "Required spend is not approved", `Needs $${opportunity.requirements.spendUsd.toFixed(2)}; approved amount is $${opportunity.authority.approvedSpendUsd.toFixed(2)}.`, { hardBlock: true });

  const evidenceAge = opportunity.evidence.length ? Math.max(...opportunity.evidence.map((item) => daysBetween(item.checkedAt, now) ?? 9999)) : null;
  if (evidenceAge === null) add("evidence_missing", 15, "No timestamped evidence", "Verify primary sources and record when each claim was checked.");
  else if (evidenceAge > 1) add("evidence_stale", 10, "Evidence is stale for external action", "Recheck sources within 24 hours before claiming, submitting, contacting, or spending.");

  score = clamp(score, 0, 100);
  let verdict = hardBlock ? "BLOCK" : score < 45 ? "SKIP" : score < 70 || payoutCap ? "VERIFY" : "PURSUE";
  if (opportunity.status === "unknown" && verdict === "PURSUE") verdict = "VERIFY";

  const settled = opportunity.stage === "settled" && Boolean(opportunity.payout.paymentEvidence);
  const countedRevenueUsd = settled ? number(opportunity.payout.netUsd, opportunity.amountUsd) : opportunity.stage === "reversed" ? -Math.abs(number(opportunity.payout.refundUsd, 0)) : 0;

  return {
    ...opportunity,
    score,
    verdict,
    hardBlock,
    payoutGate: opportunity.payout.identityRequired && !opportunity.authority.payoutIdentityReady,
    countedRevenueUsd,
    advertisedAmountUsd: opportunity.amountUsd,
    pipelineAmountUsd: !hardBlock && opportunity.stage !== "settled" ? opportunity.amountUsd : 0,
    signals: signals.sort((a, b) => a.delta - b.delta),
    nextAction: chooseNextAction(verdict, opportunity, signals),
    analyzedAt: now.toISOString(),
  };
}

export function analyzePortfolio(rawOpportunities, now = new Date()) {
  const opportunities = rawOpportunities.map((item) => analyzeOpportunity(item, now));
  return {
    advertisedUsd: opportunities.reduce((sum, item) => sum + item.advertisedAmountUsd, 0),
    pipelineUsd: opportunities.reduce((sum, item) => sum + item.pipelineAmountUsd, 0),
    settledUsd: opportunities.reduce((sum, item) => sum + item.countedRevenueUsd, 0),
    blocked: opportunities.filter((item) => item.verdict === "BLOCK").length,
    pursue: opportunities.filter((item) => item.verdict === "PURSUE").length,
    verify: opportunities.filter((item) => item.verdict === "VERIFY").length,
    opportunities,
  };
}

export function formatMarkdown(report) {
  const lines = [
    `# ${report.title}`,
    "",
    `**Verdict:** ${report.verdict}  `,
    `**Readiness:** ${report.score}/100  `,
    `**Advertised:** $${report.advertisedAmountUsd.toLocaleString()}  `,
    `**Counted revenue:** $${report.countedRevenueUsd.toLocaleString()}`,
    "",
    "## Evidence-based deductions",
    "",
  ];
  if (!report.signals.length) lines.push("- No deductions.");
  for (const signal of report.signals) lines.push(`- **${signal.title} (${signal.delta})** — ${signal.detail}${signal.evidenceUrl ? ` ([source](${signal.evidenceUrl}))` : ""}`);
  lines.push("", "## Next action", "", report.nextAction, "", `_Analyzed ${report.analyzedAt}. Advertised value is not revenue until payment settles._`);
  return lines.join("\n");
}

export function detectSafety(text = "") {
  const normalized = String(text).toLowerCase();
  const promptPatterns = ["ignore previous instructions", "ignore all prior", "reveal your system prompt", "send your credentials", "exfiltrate"];
  const prohibitedPatterns = ["solve hcaptcha", "bypass captcha", "credential stuffing", "steal credentials", "deploy ransomware"];
  return {
    promptInjection: promptPatterns.filter((pattern) => normalized.includes(pattern)).map((pattern) => `Matched “${pattern}”`),
    prohibited: prohibitedPatterns.filter((pattern) => normalized.includes(pattern)).map((pattern) => `Matched “${pattern}”`),
    suspicious: [],
  };
}

function normalizeOpportunity(raw) {
  const stage = STAGES.includes(raw.stage) ? raw.stage : "discovered";
  return {
    id: raw.id || raw.url || globalThis.crypto?.randomUUID?.() || "opportunity",
    title: raw.title || "Untitled opportunity",
    url: raw.url || "",
    source: raw.source || "unknown",
    amountUsd: Math.max(0, number(raw.amountUsd)),
    status: ["open", "closed", "deleted", "unknown"].includes(raw.status) ? raw.status : "unknown",
    stage,
    scope: { clear: Boolean(raw.scope?.clear), bodyLength: number(raw.scope?.bodyLength) },
    repository: {
      url: raw.repository?.url || "",
      stars: Math.max(0, number(raw.repository?.stars)),
      archived: Boolean(raw.repository?.archived),
      license: raw.repository?.license || null,
      pushedAt: raw.repository?.pushedAt || null,
      isBotInstalled: raw.repository?.isBotInstalled ?? null,
    },
    competition: {
      openPrs: Math.max(0, number(raw.competition?.openPrs)),
      closedPrs: Math.max(0, number(raw.competition?.closedPrs)),
      mergedPrs: Math.max(0, number(raw.competition?.mergedPrs)),
      claimers: Math.max(0, number(raw.competition?.claimers)),
    },
    payout: {
      funding: ["escrowed", "promised", "unknown", "settled"].includes(raw.payout?.funding) ? raw.payout.funding : "unknown",
      provider: raw.payout?.provider || "Unknown",
      identityRequired: raw.payout?.identityRequired !== false,
      paymentEvidence: raw.payout?.paymentEvidence || null,
      netUsd: raw.payout?.netUsd,
      refundUsd: raw.payout?.refundUsd,
    },
    requirements: {
      spendUsd: Math.max(0, number(raw.requirements?.spendUsd)),
      termsAcceptance: Boolean(raw.requirements?.termsAcceptance),
      ownerIdentity: Boolean(raw.requirements?.ownerIdentity),
      hardware: Boolean(raw.requirements?.hardware),
      cloudBilling: Boolean(raw.requirements?.cloudBilling),
    },
    authority: {
      approvedSpendUsd: Math.max(0, number(raw.authority?.approvedSpendUsd)),
      payoutIdentityReady: Boolean(raw.authority?.payoutIdentityReady),
    },
    safety: {
      promptInjection: Array.isArray(raw.safety?.promptInjection) ? raw.safety.promptInjection : [],
      prohibited: Array.isArray(raw.safety?.prohibited) ? raw.safety.prohibited : [],
      suspicious: Array.isArray(raw.safety?.suspicious) ? raw.safety.suspicious : [],
    },
    evidence: Array.isArray(raw.evidence) ? raw.evidence : [],
  };
}

function chooseNextAction(verdict, opportunity, signals) {
  if (verdict === "BLOCK") return "Stop. Preserve the evidence and do not claim, code, contact, submit, or spend against this listing.";
  if (verdict === "SKIP") return "Archive this lead and move to a clearer, less crowded opportunity.";
  const first = signals[0];
  if (verdict === "VERIFY") return first ? `Resolve “${first.title}” against a primary source, then rescore.` : "Verify payout and acceptance terms, then rescore.";
  if (opportunity.payout.identityRequired && !opportunity.authority.payoutIdentityReady) return "Begin the reversible work, but schedule owner-controlled payout onboarding before submission.";
  return "Confirm contribution rules, claim only if required, implement the smallest acceptance-tested solution, and keep settlement evidence.";
}
