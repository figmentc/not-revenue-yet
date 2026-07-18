export const DEMO_OPPORTUNITIES = [
  {
    id: "go-gitea/gitea#24635",
    title: "Gitea automatic token permissions",
    url: "https://github.com/go-gitea/gitea/issues/24635",
    source: "opire",
    amountUsd: 1880,
    status: "closed",
    stage: "discovered",
    scope: { clear: true, bodyLength: 2200 },
    repository: { url: "https://github.com/go-gitea/gitea", stars: 52000, archived: false, license: "MIT", pushedAt: "2026-07-17T00:00:00Z" },
    competition: { openPrs: 0, closedPrs: 10, mergedPrs: 1, claimers: 2 },
    payout: { funding: "promised", provider: "Opire", identityRequired: true },
    requirements: { spendUsd: 0, termsAcceptance: true, ownerIdentity: true },
    authority: { approvedSpendUsd: 0, payoutIdentityReady: false },
    safety: { promptInjection: [], prohibited: [], suspicious: [] },
    evidence: [
      { claim: "Issue is closed", url: "https://github.com/go-gitea/gitea/issues/24635", checkedAt: "2026-07-18T17:00:00Z", result: "confirmed" },
      { claim: "Implementation merged", url: "https://github.com/go-gitea/gitea/pull/36173", checkedAt: "2026-07-18T17:00:00Z", result: "confirmed" }
    ]
  },
  {
    id: "uswriting/zeroperl#7",
    title: "ZeroPerl asynchronous web APIs",
    url: "https://github.com/uswriting/zeroperl/issues/7",
    source: "opire",
    amountUsd: 1500,
    status: "deleted",
    stage: "discovered",
    scope: { clear: false, bodyLength: 0 },
    repository: { url: "https://github.com/6over3/zeroperl", stars: 21, archived: false, license: "MIT", pushedAt: "2026-05-05T00:00:00Z" },
    competition: { openPrs: 0, closedPrs: 14, mergedPrs: 1, claimers: 0 },
    payout: { funding: "promised", provider: "Opire", identityRequired: true },
    requirements: { spendUsd: 0, termsAcceptance: true, ownerIdentity: true },
    authority: { approvedSpendUsd: 0, payoutIdentityReady: false },
    safety: { promptInjection: [], prohibited: [], suspicious: [] },
    evidence: [
      { claim: "Issue is deleted", url: "https://github.com/uswriting/zeroperl/issues/7", checkedAt: "2026-07-18T17:00:00Z", result: "confirmed" },
      { claim: "Feature was merged", url: "https://github.com/6over3/zeroperl/pull/9", checkedAt: "2026-07-18T17:00:00Z", result: "confirmed" }
    ]
  },
  {
    id: "rodrigompy/bugb#1",
    title: "c1work",
    url: "https://github.com/rodrigompy/bugb/issues/1",
    source: "opire",
    amountUsd: 1160036,
    status: "open",
    stage: "discovered",
    scope: { clear: false, bodyLength: 19 },
    repository: { url: "https://github.com/rodrigompy/bugb", stars: 0, archived: false, license: null, pushedAt: "2026-06-30T00:00:00Z", isBotInstalled: false },
    competition: { openPrs: 0, closedPrs: 0, mergedPrs: 0, claimers: 0 },
    payout: { funding: "unknown", provider: "Opire", identityRequired: true },
    requirements: { spendUsd: 0, termsAcceptance: true, ownerIdentity: true },
    authority: { approvedSpendUsd: 0, payoutIdentityReady: false },
    safety: { promptInjection: [], prohibited: [], suspicious: ["Unusually large advertised amount"] },
    evidence: [
      { claim: "Listing observed", url: "https://app.opire.dev", checkedAt: "2026-07-18T17:00:00Z", result: "confirmed" }
    ]
  },
  {
    id: "electron/electron#48191",
    title: "macOS package filtering regression",
    url: "https://github.com/electron/electron/issues/48191",
    source: "opire",
    amountUsd: 70,
    status: "open",
    stage: "verified",
    scope: { clear: true, bodyLength: 1800 },
    repository: { url: "https://github.com/electron/electron", stars: 120000, archived: false, license: "MIT", pushedAt: "2026-07-18T00:00:00Z" },
    competition: { openPrs: 1, closedPrs: 0, mergedPrs: 0, claimers: 1 },
    payout: { funding: "promised", provider: "Opire", identityRequired: true },
    requirements: { spendUsd: 0, termsAcceptance: true, ownerIdentity: true },
    authority: { approvedSpendUsd: 0, payoutIdentityReady: false },
    safety: { promptInjection: [], prohibited: [], suspicious: [] },
    evidence: [
      { claim: "Issue is open", url: "https://github.com/electron/electron/issues/48191", checkedAt: "2026-07-18T17:00:00Z", result: "confirmed" }
    ]
  }
];
