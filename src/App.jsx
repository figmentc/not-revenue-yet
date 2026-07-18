import { useMemo, useState } from "react";
import { analyzeOpportunity, analyzePortfolio } from "../core/analyze.mjs";
import { fetchGithubOpportunity } from "../core/github.mjs";
import { DEMO_OPPORTUNITIES } from "../fixtures/demo-opportunities.mjs";

const money = new Intl.NumberFormat("en-US", { style: "currency", currency: "USD", maximumFractionDigits: 0 });
const demoNow = new Date("2026-07-18T18:00:00Z");

export default function App() {
  const portfolio = useMemo(() => analyzePortfolio(DEMO_OPPORTUNITIES, demoNow), []);
  const [selected, setSelected] = useState(portfolio.opportunities[0]);
  const [url, setUrl] = useState("https://github.com/go-gitea/gitea/issues/24635");
  const [amount, setAmount] = useState("1880");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const runLive = async (event) => {
    event.preventDefault();
    setLoading(true);
    setError("");
    try {
      const input = await fetchGithubOpportunity(url, { amountUsd: Number(amount), funding: "promised", provider: "Advertised platform" });
      setSelected(analyzeOpportunity(input));
    } catch (err) {
      const fallback = DEMO_OPPORTUNITIES.find((item) => item.url === url);
      if (fallback && err.message.includes("rate limit")) {
        setSelected(analyzeOpportunity(fallback, demoNow));
        setError("GitHub's anonymous rate limit was reached, so this result uses the bundled timestamped evidence snapshot.");
      } else {
        setError(err.message);
      }
    } finally {
      setLoading(false);
    }
  };

  return <main>
    <nav><a className="wordmark" href="#top"><span>NOT</span> REVENUE YET</a><div className="nav-meta">CODEX PLUGIN · READ-ONLY BY DEFAULT</div></nav>

    <section className="hero" id="top">
      <div className="eyebrow">A proof layer for autonomous earning agents</div>
      <h1>A listing is a claim.<br /><em>Cash is a fact.</em></h1>
      <p className="lede">Before an agent spends hours on a bounty, contest, or contract, Not Revenue Yet checks the work target, duplicate implementations, payout evidence, safety, authority, and settlement state.</p>
      <div className="hero-actions"><a className="button primary" href="#lab">Run the evidence lab</a><a className="button ghost" href="https://github.com/figmentc/not-revenue-yet">Install the plugin ↗</a></div>
      <div className="hero-rule"><span>01 VERIFY</span><i></i><span>02 ACT</span><i></i><span>03 SETTLE</span></div>
    </section>

    <section className="truth-strip">
      <Metric label="Advertised across four live-looking leads" value={money.format(portfolio.advertisedUsd)} tone="danger" />
      <Metric label="Still plausible after evidence gates" value={money.format(portfolio.pipelineUsd)} tone="warn" />
      <Metric label="Counted as settled revenue" value={money.format(portfolio.settledUsd)} tone="safe" />
    </section>

    <section className="lab" id="lab">
      <div className="section-head"><div><div className="eyebrow">Evidence lab</div><h2>Make the opportunity prove itself.</h2></div><p>Paste a public GitHub issue. The browser checks live repository state without credentials; the plugin adds platform rules and owner authority.</p></div>
      <form className="scan-form" onSubmit={runLive}>
        <label><span>GitHub issue</span><input value={url} onChange={(event) => setUrl(event.target.value)} aria-label="GitHub issue URL" /></label>
        <label className="amount"><span>Advertised USD</span><input value={amount} inputMode="numeric" onChange={(event) => setAmount(event.target.value)} aria-label="Advertised amount" /></label>
        <button disabled={loading}>{loading ? "Checking…" : "Verify live"}</button>
      </form>
      {error && <p className="error">{error}</p>}

      <div className="case-layout">
        <div className="case-list">
          <div className="case-list-title">Verified demo cases <span>{portfolio.opportunities.length}</span></div>
          {portfolio.opportunities.map((item) => <button key={item.id} className={`case-row ${selected.id === item.id ? "active" : ""}`} onClick={() => setSelected(item)}>
            <Verdict value={item.verdict} /><div><strong>{item.title}</strong><small>{item.source} · {money.format(item.amountUsd)}</small></div><b>{item.score}</b>
          </button>)}
        </div>
        <Report item={selected} />
      </div>
    </section>

    <section className="pipeline">
      <div className="eyebrow">The accounting guardrail</div><h2>Agents love progress. Ledgers require proof.</h2>
      <div className="stages">{["Discovered", "Verified", "Building", "Submitted", "Accepted", "Settled"].map((stage, index) => <div className={stage === "Settled" ? "settled" : ""} key={stage}><span>{String(index + 1).padStart(2, "0")}</span><strong>{stage}</strong><small>{stage === "Settled" ? "Counts" : "$0 revenue"}</small></div>)}</div>
    </section>

    <section className="system">
      <div className="section-head"><div><div className="eyebrow">Inside the plugin</div><h2>One prompt. Four independent gates.</h2></div></div>
      <div className="gate-grid">
        <Gate n="A" title="Reality" text="Is the source live, open, current, and not already completed?" />
        <Gate n="B" title="Payout" text="Is the money escrowed, promised, unknown, or actually settled?" />
        <Gate n="C" title="Authority" text="Can the agent act, or does this require identity, terms, or spending approval?" />
        <Gate n="D" title="Safety" text="Does untrusted content contain injection, abuse, bypass, or credential requests?" />
      </div>
      <pre><code><span>$</span> not-revenue-yet vet https://github.com/org/repo/issues/123 --amount 500{"\n"}<b>VERIFY · 62/100 · $500 advertised · $0 settled</b>{"\n"}Next: verify reward funding against the platform lifecycle.</code></pre>
    </section>

    <footer><div><strong>NOT REVENUE YET</strong><p>Built with Codex and GPT-5.6 during OpenAI Build Week.</p></div><p>No bank access. No invented probability. No payout guarantee.</p></footer>
  </main>;
}

function Metric({ label, value, tone }) { return <div className={`metric ${tone}`}><small>{label}</small><strong>{value}</strong></div>; }
function Verdict({ value }) { return <span className={`verdict ${value.toLowerCase()}`}>{value}</span>; }
function Gate({ n, title, text }) { return <article><span>{n}</span><h3>{title}</h3><p>{text}</p></article>; }

function Report({ item }) {
  return <article className="report">
    <div className="report-top"><div><Verdict value={item.verdict} /><h3>{item.title}</h3><a href={item.url}>{item.id} ↗</a></div><div className="score"><strong>{item.score}</strong><span>/100</span><small>readiness</small></div></div>
    <div className="money-grid"><div><small>Advertised</small><b>{money.format(item.advertisedAmountUsd)}</b></div><div><small>Pipeline</small><b>{money.format(item.pipelineAmountUsd)}</b></div><div><small>Settled</small><b>{money.format(item.countedRevenueUsd)}</b></div></div>
    <div className="deductions"><h4>Why the number moved</h4>{item.signals.slice(0, 5).map((signal) => <div className="signal" key={signal.code}><span>{signal.delta}</span><p><strong>{signal.title}</strong>{signal.detail}</p></div>)}</div>
    <div className="next"><small>SAFE NEXT ACTION</small><p>{item.nextAction}</p></div>
  </article>;
}
