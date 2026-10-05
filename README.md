# SatsPermit

**Task-bound payment permissions for AI agents.**

A runnable, single-user hackathon prototype. Approve one purchase, challenge it with controlled adversarial requests, then inspect the gateway's decision and delivered service result.

## Start in Windows

1. Install **Node.js 24 or newer** if it is not already installed.
2. Extract the archive and open the `satspermit` folder.
3. Double-click `START.bat`.
4. Open **http://127.0.0.1:4317** in your browser.
5. Paste the **Owner access key** printed in the server window into the login screen.
6. Click **Run guided demo**.

No npm install, API key, wallet, Bitcoin, Docker or account is needed for the default demo. Keep the server window open while using the application. If that address is already running, use it rather than starting a second copy.

From a terminal in this folder:

```powershell
npm start
```

## What works now

- Persistent SQLite tasks, permissions, invoice bindings and evidence.
- Explicit user approval before an agent can execute a purchase.
- Exact invoice, provider, document hash, amount and expiry validation.
- Owner access key and task-scoped agent capabilities, with separate authority.
- Downloadable task permissions and a standalone external-agent client.
- Bounded live-agent loop with gateway tool feedback and a visible transcript.
- Atomic reservation: concurrent requests cannot initiate a second payment.
- Persistent simulated wallet, including payment proof and attempt history.
- Unknown outcomes stay locked; reconciliation queries the wallet instead of resending.
- Startup recovery changes interrupted `paying` tasks to `uncertain`.
- A real deterministic document-analysis service returns word count, sentence count, keywords and estimated reading time for the input you supplied.
- Evidence filtering, task history, full JSON export and an independent integrity verifier. Credentials, raw invoices, document bodies and payment preimages are excluded.
- Optional Gemini function-calling adapter and NWC faucet adapter (see verification limits).

## Be precise about the demo

The default wallet is a **local simulator**. Its HMAC-authenticated `spdemo.` envelopes are not BOLT11 invoices. Its balances and settlements are not Bitcoin or Lightning transactions.

The default attack buttons replay controlled adversarial tool calls. They **do not claim that a live AI model was compromised**. The document service performs deterministic local analysis, not LLM summarisation or transcription.

The optional NWC Faucet also uses dummy balances, according to its own documentation. Testing a protocol against that service is not proof of mainnet settlement.

## Two-minute presentation

| Time | Action |
| --- | --- |
| 0:00–0:15 | Explain: a budget does not specify which purchase a user authorised. State that this demonstration uses simulated funds and adversarial replays. |
| 0:15–0:35 | Enter a document, request its 40-sat quote, and approve that exact purchase under a 100-sat ceiling. |
| 0:35–0:55 | Replay the separate 20-sat invoice. It is within budget but gets rejected for `INVOICE_MISMATCH`. Wallet calls remain zero. |
| 0:55–1:15 | Click **Race 10 requests**. One request settles, nine are blocked, and the document result appears. |
| 1:15–1:40 | Create and approve a second task. Click **Lose the wallet response**. Show the uncertain, locked permission. Click **Check wallet outcome**; the payment is reconciled without another wallet call. |
| 1:40–2:00 | Open Evidence log, export JSON and show the test suite. Say: “The agent can request a payment. It cannot expand its permission.” |

Use **Run guided demo** for a shorter, reproducible invoice-swap plus concurrency demonstration. It creates and approves a dummy task automatically. The manual workflow separately demonstrates explicit approval.

## Run the security tests

```powershell
npm test
```

The 25 tests cover legitimate delivery, missing approval, cheaper invoice substitution, provider/document substitution, malformed and tampered invoices, expiry/revocation, cross-task capabilities, concurrency, repeats, timeouts, invalid preimages, multi-connection reservation, restart recovery, inconsistent quote metadata, malformed requests, model correction after a denied invoice, refusal, ambiguous tool calls, model outages, bounded retries, and full evidence verification.

Tests use temporary databases. The application data under `data/` is separate and is never included in the source archive.

## Connect your own agent

Create a task, approve it, expand **Connect your own agent**, and download `permission.json`. Move it into this project folder and run:

```powershell
npm run agent -- permission.json
```

The example client calls only `/agent/pay` with a task bearer capability. It does not use an owner cookie or wallet key. A second run is rejected as `ALREADY_PURCHASED`. A request made before approval is rejected as `NOT_APPROVED`. Keep permission files private; do not include them in a repository or presentation. Revoke an unused permission in the UI. Restarting the server does not erase permissions; downloading a new capability after restart rotates that task's token.

For an existing agent, POST the downloaded `request` JSON to the supplied `endpoint` with `Authorization: Bearer <token>`. The endpoint accepts a payment request only; it cannot create, approve or amend a task. Do not automatically retry an uncertain payment. The owner must reconcile it through the dashboard.

## Verify an export independently

```powershell
npm run verify -- satspermit-evidence.json
npm run verify -- satspermit-evidence.json previously-recorded-root
```

The verifier checks event ordering, hash links, event content, count and root. It detects changes relative to an independently preserved root. It does not prove Bitcoin settlement or make the log tamper-proof.

## Optional live Gemini agent

Copy `.env.example` to `.env` and add your key locally:

```dotenv
WALLET_MODE=local-simulator
GEMINI_API_KEY=your-key
GEMINI_MODEL=gemini-2.5-flash
```

Choose a model available to your Google account if that default is unavailable. Restart the server. Create and approve a task; **Run agent** will become available.

The gateway sends the task title, budget, controlled service-response fixture and tool definition to Google. It does not send the document body, wallet credentials, owner session or task capability. The model may request the approved invoice, request the verification invoice or refuse. The gateway applies the same independent checks in all cases. The bounded loop allows at most two payment requests and one final explanation. Each request receives the actual gateway result. Tool calls stop after settlement or an uncertain outcome. The transcript is model output; the independently recorded task status remains authoritative. The model and network may refuse or fail; no payment is automatically retried.

Do not paste an API key into the document field, chat, source files or a public repository. `.env` is ignored by Git.

## Optional NWC dummy-wallet integration

This path requires network access and the pinned external dependencies. **Verified against NWC Faucet on October 2, 2026:** payer/merchant discovery, BOLT11 invoice decoding, mismatched-invoice rejection, one dummy payment, matching preimage, invoice lookup, service delivery and duplicate rejection. This is protocol integration with dummy balances, not real Bitcoin settlement.

```powershell
npm ci
npm run sandbox
npm start
```

`npm run sandbox` calls the documented faucet endpoint twice and writes the returned payer/merchant connections into a new `.env`. It refuses to overwrite an existing `.env` and does not print secrets. If you already have `.env`, configure it manually using freshly created dummy-wallet connections and the variable names in `.env.example`.

The NWC adapter requests fixed-amount invoices from the configured merchant, decodes them using `bolt11`, calls `payInvoice`, and uses `lookupInvoice` for uncertain outcomes. The local provider supplies the document analysis after verified settlement. The optional dependencies are dynamically imported only in NWC mode. The manifest and lockfile pin `@getalby/sdk` 8.0.3 and `bolt11` 1.4.1. The default simulator still runs without installing dependencies.

Dependency review: `npm audit` reported three low-severity package entries on October 2, 2026, all arising from the same `elliptic` advisory through `bolt11` / `secp256k1` ([GHSA-848j-6mx2-7j84](https://github.com/advisories/GHSA-848j-6mx2-7j84)). No compatible fix was offered; the suggested change was a major downgrade. The adapter uses `bolt11` for invoice decoding, not wallet signing. No claim of an audited or real-money-ready dependency stack is made.

NWC mode disables the automatic guided demo, concurrent-race scenario and simulated timeout controls. Approve and execute an individual purchase manually. **Never configure a wallet containing real funds for this prototype.** Fee ceilings, custody/provider assumptions, wallet-specific failure semantics and hardening still need work before a real-money application.

## Trust boundary

The owner UI is a local control plane. It creates and approves permissions. The agent has only a task-specific bearer capability for `/agent/pay`. It cannot call owner APIs with that capability. The gateway owns the wallet connection, database and atomic state transitions.

The server binds only to `127.0.0.1`, validates the Host/Origin, rejects cross-site browser requests, and requires an owner access key before issuing an owner cookie. Owner mutations also require a CSRF header. Visiting the public shell or holding an agent capability cannot create an owner session. It sends restrictive CSP and frame headers.

**Local-host trust is assumed.** The owner key blocks unauthenticated local HTTP clients, but a program with access to the server environment, terminal, database or owner browser can still compromise the system. This is not a hardened multi-user service. A compromised host or gateway can bypass the security model. Do not expose the port publicly, and do not give an AI unrestricted filesystem, shell or owner-browser access to this machine while claiming isolation.

The prototype enforces one purchase per explicit approved task. It cannot detect that a human has created two semantically identical tasks. Permission binding does not guarantee merchant honesty, output quality or privacy. No global “all prompt injection is blocked” claim is made.

The evidence log is hash-linked to make an exported sequence inspectable. A local database administrator could rewrite it and recompute every hash. There is no external timestamp, signature anchor or tamper-proof guarantee. The UI shows the latest 500 events. Exports include the complete chain, event count and root. Use **Verify full log** in the UI, or run the standalone verifier against a downloaded export. Record its root separately; self-consistency alone cannot detect an entirely rewritten log or a truncation with a recomputed root. Task snapshots and wallet metrics are not cryptographically bound by this verifier.

## Layout

```text
src/gateway.ts        Permission lifecycle, atomic execution, evidence, document service
src/wallet.ts         Persistent local simulator and optional NWC adapter
src/server.ts         Local HTTP API, owner/agent separation, scenario runner
src/agent-loop.ts     Bounded Gemini function-calling integration
src/evidence.ts       Exported event-chain integrity checking
public/              Responsive dashboard (no external assets)
tests/               25 gateway, agent and evidence tests
scripts/             Agent client, evidence verifier, HTTP checks, dummy-wallet setup
data/                Runtime SQLite files; created at launch, never ship these
```

The code uses TypeScript syntax stripped natively by Node 24. There is no bundler, compiler or dependency installation on the default path. Runtime tests were executed; a separate TypeScript type-check was not run.

## Verification performed on October 2, 2026

- **PASS:** 25 gateway, agent-loop and evidence tests. Agent tests use controlled model responses; they are not live Gemini tests.
- **PASS:** server and browser-JavaScript syntax checks.
- **PASS:** HTTP integration checks for session isolation, CSRF, Origin, task capabilities, owner approval, payment, repeated-payment rejection and evidence redaction.
- **PASS:** guided-demo and lost-response/reconciliation API workflows.
- **PASS:** real Chrome browser workflow: owner login, guided demo, evidence filtering/verification, lost-response recovery, desktop/mobile overflow and console checks. Desktop and mobile screenshots inspected.
- **NOT VERIFIED:** live Gemini requests (no API key supplied).
- **PASS:** external NWC Faucet adapter integration using the pinned packages. The SDK v8 import was corrected during this check. Evidence is included in the release bundle.

This release is a working local hackathon application. Real-money deployment, multi-user hosting and a live Gemini run are outside its verified scope.

## Primary references

- NIP-47: https://github.com/nostr-protocol/nips/blob/master/47.md
- Alby NWC SDK: https://guides.getalby.com/developer-guide/developer-guide/nostr-wallet-connect-api/building-lightning-apps/nwc-js-sdk
- Dummy-wallet faucet: https://faucet.nwc.dev/
- Gemini function calling: https://ai.google.dev/gemini-api/docs/function-calling
- BOLT11: https://github.com/lightning/bolts/blob/master/11-payment-encoding.md

## Attribution and licence

MIT licence. This prototype uses Node.js built-ins by default. Optional Alby/bolt11 dependencies retain their own licences. Nostr Wallet Connect, budgets and confirmation gates predate this project; SatsPermit makes no first-invention claim.
