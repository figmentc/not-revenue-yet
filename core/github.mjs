import { detectSafety } from "./analyze.mjs";

export function parseGithubIssueUrl(value) {
  const url = new URL(value);
  if (url.hostname !== "github.com") throw new Error("Expected a github.com issue URL");
  const parts = url.pathname.split("/").filter(Boolean);
  if (parts.length < 4 || parts[2] !== "issues" || !/^\d+$/.test(parts[3])) throw new Error("Expected https://github.com/OWNER/REPO/issues/NUMBER");
  return { owner: parts[0], repo: parts[1], number: Number(parts[3]), url: `https://github.com/${parts[0]}/${parts[1]}/issues/${parts[3]}` };
}

export async function fetchGithubOpportunity(issueUrl, options = {}) {
  const parsed = parseGithubIssueUrl(issueUrl);
  const headers = { Accept: "application/vnd.github+json", "X-GitHub-Api-Version": "2022-11-28" };
  const token = options.token || (typeof process !== "undefined" ? process.env.GITHUB_TOKEN || process.env.GH_TOKEN : null);
  if (token) headers.Authorization = `Bearer ${token}`;
  const request = async (path, accept404 = false) => {
    const response = await fetch(`https://api.github.com${path}`, { headers });
    if (accept404 && (response.status === 404 || response.status === 410)) return null;
    if (!response.ok) throw new Error(`GitHub API ${response.status}: ${await response.text()}`);
    return response.json();
  };

  const issue = await request(`/repos/${parsed.owner}/${parsed.repo}/issues/${parsed.number}`, true);
  const repo = await request(`/repos/${parsed.owner}/${parsed.repo}`);
  const timeline = issue ? await request(`/repos/${parsed.owner}/${parsed.repo}/issues/${parsed.number}/timeline`).catch(() => []) : [];
  const related = timeline.filter((event) => event.event === "cross-referenced" && event.source?.issue?.pull_request).map((event) => event.source.issue);
  const mergedPrs = related.filter((pr) => pr.pull_request?.merged_at).length;
  const openPrs = related.filter((pr) => pr.state === "open").length;
  const closedPrs = related.filter((pr) => pr.state === "closed" && !pr.pull_request?.merged_at).length;
  const text = `${issue?.title || ""}\n${issue?.body || ""}`;
  const checkedAt = new Date().toISOString();

  return {
    id: `${parsed.owner}/${parsed.repo}#${parsed.number}`,
    title: issue?.title || `${parsed.owner}/${parsed.repo}#${parsed.number}`,
    url: parsed.url,
    source: options.source || "github",
    amountUsd: Number(options.amountUsd || extractAdvertisedAmount(text) || 0),
    status: issue ? issue.state : "deleted",
    stage: "discovered",
    scope: { clear: Boolean(issue?.body && issue.body.length >= 120), bodyLength: issue?.body?.length || 0 },
    repository: {
      url: repo.html_url,
      stars: repo.stargazers_count,
      archived: repo.archived,
      license: repo.license?.spdx_id || null,
      pushedAt: repo.pushed_at,
    },
    competition: { openPrs, closedPrs, mergedPrs, claimers: Number(options.claimers || 0) },
    payout: { funding: options.funding || "unknown", provider: options.provider || "Unknown", identityRequired: true },
    requirements: { spendUsd: Number(options.spendUsd || 0), termsAcceptance: true, ownerIdentity: true },
    authority: { approvedSpendUsd: Number(options.approvedSpendUsd || 0), payoutIdentityReady: Boolean(options.payoutIdentityReady) },
    safety: detectSafety(text),
    evidence: [
      { claim: `GitHub target is ${issue ? issue.state : "deleted"}`, url: parsed.url, checkedAt, result: "confirmed" },
      { claim: "Repository state checked", url: repo.html_url, checkedAt, result: "confirmed" },
    ],
  };
}

function extractAdvertisedAmount(text) {
  const matches = [...text.matchAll(/\$\s?([0-9][0-9,]*(?:\.\d{1,2})?)(k)?\b/gi)];
  if (!matches.length) return null;
  return Math.max(...matches.map((match) => Number(match[1].replaceAll(",", "")) * (match[2] ? 1000 : 1)));
}
