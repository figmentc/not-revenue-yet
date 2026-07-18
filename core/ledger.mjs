const COUNTED_KINDS = new Set(["settled", "refund", "chargeback"]);

export function summarizeLedger(events, currency = "USD") {
  const seen = new Set();
  const accepted = [];
  const ignored = [];
  let settledMinor = 0;

  for (const raw of events) {
    const event = normalizeEvent(raw);
    if (seen.has(event.idempotencyKey)) {
      ignored.push({ ...event, reason: "duplicate_idempotency_key" });
      continue;
    }
    seen.add(event.idempotencyKey);
    if (event.currency !== currency) {
      ignored.push({ ...event, reason: "currency_mismatch" });
      continue;
    }
    accepted.push(event);
    if (event.kind === "settled" && event.evidence?.reference) settledMinor += event.netMinor;
    if ((event.kind === "refund" || event.kind === "chargeback") && event.evidence?.reference) settledMinor -= Math.abs(event.netMinor);
  }

  return {
    currency,
    settledMinor,
    settledUsd: currency === "USD" ? settledMinor / 100 : null,
    countedEvents: accepted.filter((event) => COUNTED_KINDS.has(event.kind) && event.evidence?.reference).length,
    pipelineEvents: accepted.filter((event) => !COUNTED_KINDS.has(event.kind)).length,
    accepted,
    ignored,
  };
}

export function normalizeEvent(raw) {
  if (!raw || typeof raw !== "object") throw new Error("Ledger event must be an object");
  if (!raw.eventId || !raw.idempotencyKey) throw new Error("Ledger event requires eventId and idempotencyKey");
  if (!["promised", "approved", "paid-pending", "settled", "refund", "chargeback"].includes(raw.kind)) throw new Error(`Unsupported ledger kind: ${raw.kind}`);
  if (!Number.isInteger(raw.netMinor)) throw new Error("netMinor must be an integer");
  return {
    eventId: String(raw.eventId),
    opportunityKey: String(raw.opportunityKey || "unknown"),
    kind: raw.kind,
    grossMinor: Number.isInteger(raw.grossMinor) ? raw.grossMinor : raw.netMinor,
    feesMinor: Number.isInteger(raw.feesMinor) ? raw.feesMinor : 0,
    netMinor: raw.netMinor,
    currency: String(raw.currency || "USD").toUpperCase(),
    occurredAt: raw.occurredAt || null,
    idempotencyKey: String(raw.idempotencyKey),
    evidence: raw.evidence || null,
  };
}
