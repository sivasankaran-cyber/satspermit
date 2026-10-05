# SatsPermit: two-minute judge demo

Before recording: run `START.bat`, unlock the workspace using the owner key from the server window, and keep that key out of the recording. Use simulator mode. For a clean recording, select a new, empty data directory with `SATSPERMIT_DATA_DIR`; do not delete an existing wallet database. Confirm Node 24 is installed.

**0:00–0:20 — The problem**

“An AI agent can read malicious instructions inside a service response. Giving it a spending budget does not tell the wallet what I intended to buy. I built SatsPermit to bind one permission to one exact purchase. This demo uses simulated funds and controlled attack requests.”

**0:20–0:40 — The permission**

Enter a document, get its 40-sat quote, and approve it under a 100-sat ceiling.

“I approved this document, this provider and this invoice, once.”

**0:40–1:00 — The attack**

Click **Swap the invoice**. Show `INVOICE_MISMATCH` and the unchanged wallet-call count.

“The service asks for a different 20-sat payment. It fits my budget. It does not fit my permission. The gateway rejects it before contacting the wallet.”

**1:00–1:20 — Concurrency**

Click **Race 10 requests**. Show one settled purchase, nine rejections and the delivered document analysis.

“Ten requests competed for the same permission. The database reserved it before the wallet call. Only one request reached the wallet.”

**1:20–1:45 — Failure recovery**

Create and approve a second task. Click **Lose the wallet response**, then **Check wallet outcome**.

“A timeout does not prove payment failed. SatsPermit locks the permission and checks the existing payment. The wallet-call count does not increase.”

**1:45–2:00 — Evidence and scope**

Open **Evidence log**, click **Verify full log**, and download JSON.

“The log is independently checkable against a saved root. A task token cannot unlock the owner dashboard. The NWC adapter also passed a separate external dummy-wallet test. This recording demonstrates the gateway with a simulator; a live Gemini run requires an API key.”

Fallback: **Run guided demo** executes invoice substitution plus the ten-request race. It creates an approved dummy task automatically; explain that the manual workflow is what demonstrates owner approval.

Do not call simulated sats real Bitcoin, replayed attacks live model compromises, or a hash chain tamper-proof. A live model refusing the malicious instruction is a valid result, not a failed demo.
