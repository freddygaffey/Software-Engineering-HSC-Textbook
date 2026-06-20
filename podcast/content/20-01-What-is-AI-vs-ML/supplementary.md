---
title: "Supplementary Materials — 20.1: What Is AI vs ML"
module: SA
lesson: "20.1"
script: script.md
---

# Supplementary Materials

Code listings and NESA-style pseudocode for this episode. Nothing here is spoken in the
audio — it's the read-along reference.

### Listing 1 — The expert system: rule-based ticket sorting (AI, no learning)

Knowledge lives in human-written rules. It counts keyword matches and picks the
best-fitting category. Transparent — you can read exactly why it decided — but blind to
anything no rule covers.

```python
class CustomerServiceExpertSystem:
    """Traditional AI: predefined rules, no learning from data."""

    def __init__(self):
        self.rules = {
            "account_issues":  {"keywords": ["password", "login", "account", "access"]},
            "billing_issues":  {"keywords": ["bill", "charge", "payment", "refund", "invoice"]},
            "general_inquiry": {"keywords": ["hours", "location", "contact", "information"]},
        }

    def classify_ticket(self, text: str) -> dict:
        text = text.lower()
        scores = {
            category: sum(kw in text for kw in rule["keywords"])
            for category, rule in self.rules.items()
        }
        best = max(scores, key=scores.get)
        if scores[best] == 0:            # nothing matched → fall back
            best = "general_inquiry"
        return {"category": best,
                "reasoning": f"matched {scores[best]} keyword(s) for {best}"}
```

### Listing 2 — The same keyword-scoring rule in NESA pseudocode

How you'd write the expert system's core logic for exam marks.

```text
BEGIN ClassifyTicket(text)
    bestCategory ← "general_inquiry"
    bestScore    ← 0
    FOR each category IN rules
        score ← 0
        FOR each keyword IN category.keywords
            IF keyword IS IN text THEN
                score ← score + 1
            ENDIF
        NEXT keyword
        IF score > bestScore THEN
            bestScore    ← score
            bestCategory ← category.name
        ENDIF
    NEXT category
    RETURN bestCategory
END ClassifyTicket
```

### Listing 3 — The ML classifier: same job, learned from data

No rules are handed in. It is given labelled past tickets, learns which words go with
which category, then predicts a category *and* a confidence. Feed it more data and it
retrains — improving without anyone rewriting rules.

```python
import statistics

class CustomerServiceMLSystem:
    """ML: learns word/category patterns from labelled tickets."""

    def __init__(self):
        self.feature_weights = {}   # category -> {word: average frequency}
        self.is_trained = False

    def features(self, text: str) -> dict:
        words = text.lower().split()
        vocab = ["password", "login", "account", "access", "bill", "charge",
                 "payment", "refund", "invoice", "hours", "location", "contact"]
        return {w: sum(w in token for token in words) for w in vocab}

    def train(self, examples: list[tuple[str, str]]) -> None:
        """examples: list of (ticket_text, correct_category)."""
        by_category: dict[str, list[dict]] = {}
        for text, category in examples:
            by_category.setdefault(category, []).append(self.features(text))
        self.feature_weights = {
            category: {w: statistics.mean(f[w] for f in feats) for w in feats[0]}
            for category, feats in by_category.items()
        }
        self.is_trained = True

    def predict(self, text: str) -> dict:
        feats = self.features(text)
        scores = {
            category: sum(feats[w] * weight for w, weight in weights.items())
            for category, weights in self.feature_weights.items()
        }
        best = max(scores, key=scores.get)
        confidence = scores[best] / (sum(scores.values()) or 1)
        return {"category": best, "confidence": f"{confidence:.0%}"}

    def update(self, new_examples) -> None:
        self.train(new_examples)    # retrain → gets better with more data
```

### Listing 4 — RPA: the invoice bot working through the screen

Task-level automation. The bot reads values off one application's screen, holds them on a
clipboard, switches systems, and types them in — simulating a human's keystrokes, not
understanding anything.

```python
class RPABot:
    """Drives applications through their UI, like a person would."""

    def __init__(self, name: str):
        self.name = name
        self.clipboard = {}
        self.log = []

    def read_field(self, screen: dict, field: str):
        value = screen.get(field)
        self.log.append(f"READ {field} = {value}")
        return value

    def type_into(self, screen: dict, field: str, value) -> None:
        screen[field] = value
        self.log.append(f"TYPE {value} -> {field}")


def process_invoice(bot: RPABot, invoice_screen: dict, accounting_screen: dict) -> None:
    # 1. Read the invoice details off the screen
    number = bot.read_field(invoice_screen, "invoice_number")
    amount = bot.read_field(invoice_screen, "total_amount")
    # 2. Hold them on the clipboard, switch systems, type them in
    bot.clipboard.update(number=number, amount=amount)
    bot.type_into(accounting_screen, "invoice_ref_field", bot.clipboard["number"])
    bot.type_into(accounting_screen, "amount_field", bot.clipboard["amount"])
```

### Listing 5 — The RPA invoice workflow in NESA pseudocode

```text
BEGIN ProcessInvoices
    OPEN email inbox
    FOR each email IN inbox
        IF email contains an invoice THEN
            OPEN invoice viewer
            number ← READ invoice_number FROM screen
            amount ← READ total_amount FROM screen
            COPY number, amount TO clipboard
            SWITCH TO accounting system
            TYPE number INTO invoice_ref_field
            TYPE amount INTO amount_field
            SAVE record
        ENDIF
    NEXT email
END ProcessInvoices
```

### Listing 6 — BPA: orchestrating the whole onboarding process

Process-level automation. Not one task — a whole chain across systems, with human
approvals woven in and an audit trail of every step.

```python
from enum import Enum

class TaskType(Enum):
    AUTOMATED = "automated"
    APPROVAL  = "human_approval"

class BPAEngine:
    """Runs a multi-step workflow: knows the next step, waits on people, logs all."""

    def __init__(self):
        self.handlers = {}      # automated step name -> function
        self.audit = []

    def run(self, tasks: list[tuple[str, TaskType]], data: dict) -> None:
        for name, kind in tasks:
            if kind is TaskType.APPROVAL:
                self.audit.append(f"WAIT for human approval: {name}")
                if not self.request_approval(name, data):
                    self.audit.append(f"STOP — {name} rejected")
                    return
            else:
                self.handlers[name](data)            # call the system integration
                self.audit.append(f"DONE {name}")

    def request_approval(self, name: str, data: dict) -> bool:
        return True            # a real engine pauses here for a manager/HR sign-off


# Employee onboarding as an ordered process
onboarding = [
    ("validate_documents", TaskType.AUTOMATED),
    ("manager_approval",   TaskType.APPROVAL),
    ("provision_accounts", TaskType.AUTOMATED),
    ("setup_payroll",      TaskType.AUTOMATED),
    ("hr_signoff",         TaskType.APPROVAL),
    ("order_equipment",    TaskType.AUTOMATED),
    ("send_welcome_email", TaskType.AUTOMATED),
]
```

### Listing 7 — ML augmenting RPA and BPA together

The pattern that ties the lesson together: ML handles the judgement and the messiness
(classify the document, flag the anomaly), while rule-based automation handles the
reliable plumbing (RPA extracts structured data, BPA routes it).

```python
def process_document(document, ml_classifier, anomaly_detector, rpa_bot, bpa_engine):
    # 1. ML: judgement — what is this, and is anything odd?
    doc_type   = ml_classifier.classify(document)          # e.g. "invoice", 0.94
    fields     = rpa_bot.extract_structured_data(document) # 2. RPA: reliable extraction
    anomalies  = anomaly_detector.detect(fields)           # e.g. amount = $999,000

    # 3. Decide a route from ML's verdict, then let BPA drive the workflow
    if anomalies:
        queue = "human_review"        # the weird ones go to a person
    else:
        queue = f"{doc_type}_auto"    # the clean ones flow straight through
    bpa_engine.route(document, queue)
    return {"type": doc_type, "anomalies": anomalies, "queue": queue}
```

