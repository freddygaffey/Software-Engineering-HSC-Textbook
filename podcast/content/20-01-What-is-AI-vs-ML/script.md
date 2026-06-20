---
title: "What Is AI vs ML (and Where RPA and BPA Fit)"
module: SA
lesson: "20.1"
kind: lesson
supplementary: supplementary.md
---

# Lecture Script — 20.1: What Is AI vs ML (and Where RPA and BPA Fit)

Welcome back. Today we're untangling four terms that get thrown around like they all mean the same thing — Artificial Intelligence, Machine Learning, RPA, and BPA. By the end of this session you'll be able to tell them apart in a sentence, and — more importantly — know when you'd reach for each one. Let's get into it.

Here's the trap. Walk into any office and you'll hear someone say "we're using AI to do that" when what they actually mean is "we wrote some if-statements." These words have real, specific meanings, and as software engineers you need to use them precisely — because choosing the wrong tool for a problem is expensive, and promising AI when you've shipped a rule-book sets everyone up for disappointment.

So let's start at the top, with the two biggest words: AI and ML.

Artificial Intelligence is the broad field. It's the whole umbrella — any system that does something we'd normally need human intelligence for. Reasoning, perceiving, deciding, solving problems. Notice what I did not say: I didn't say learning. That's the key. An AI system might learn, or it might not. A chess engine from the 1980s that follows hand-written strategy is AI. It never learns a thing — but it plays a smart game of chess.

Machine Learning is narrower. ML is a subset of AI — picture a small circle sitting inside the big AI circle. What makes something ML is that it improves its performance by learning patterns from data, automatically, without a human writing out every rule. Recommendation systems, fraud detection, image classification — these get better as they see more examples.

So hold onto that one-line distinction: AI is the goal — behaving intelligently. ML is one particular way of getting there — learning from data.

Now, the textbook makes this concrete with two little Python systems, and I want to walk you through the idea of each, because the contrast is the whole lesson.

The first system is a customer-service expert system. Imagine a help desk that needs to sort incoming tickets — is this about billing, about your account, or just a general question? The expert-system approach is pure AI-without-learning: a human sits down and writes the rules. If the message contains the words password, login, or access — send it to technical support. It counts keyword matches and picks the best fit. Predictable, transparent, and you can read exactly why it made every decision. But here's the catch — if a new kind of problem shows up that nobody wrote a rule for, the system is blind to it. To improve it, a human has to go back in and add more rules by hand.

The second system solves the same ticket-sorting problem, but it's Machine Learning. Instead of being handed rules, it's handed examples — a pile of past tickets where we already know the correct category. It studies them, works out which words tend to go with which category, and builds its own internal sense of the patterns. Then when a fresh ticket arrives, it predicts a category and gives you a confidence score. And the magic moment: feed it more historical data, and it retrains and gets better — no human rewriting rules. The trade-off? It needs that training data to exist, and its reasoning is less transparent — the patterns are buried in numbers, not spelled out in plain English.

So put those side by side and you've got the heart of it. Rule-based AI: knowledge comes from humans, it's predictable and transparent, but it only improves when a person updates it. Machine Learning: knowledge comes from data, it adapts and improves on its own, but it needs training data and it's harder to peek inside.

Right — now let's bring in the other two characters: RPA and BPA. These are about automation, and they sit at different scales.

RPA — Robotic Process Automation. Think of RPA as a software robot that uses your applications the way a person would. It clicks buttons, reads what's on the screen, types into forms, copies a value from one system and pastes it into another. It's working at the surface — through the user interface — and it follows a fixed script. The textbook's example is invoice processing: the bot opens the email, reads the invoice details off the screen, holds them on a clipboard, switches to the accounting system, and types them in. It is tireless and exact at repetitive, rule-based tasks. But it's literally just simulating a human's keystrokes — it isn't understanding anything. The key word for RPA is task.

BPA — Business Process Automation — operates one level up. BPA isn't about automating a single task; it's about redesigning and orchestrating an entire process, end to end, often stitching multiple systems together and weaving in human approvals along the way. The textbook's example is employee onboarding. That's not one click — it's a whole chain: validate the new hire's documents, get the manager's approval, provision their accounts, set up payroll, get HR sign-off, order their equipment, send the welcome email. BPA is the engine that drives that whole workflow, knows which step comes next, pauses to wait for a human to approve, and keeps an audit trail of everything that happened. The key word for BPA is process.

So, quick contrast: RPA automates the steps that already exist, one task at a time, on the surface. BPA redesigns the whole workflow, connects systems deeply, and builds human decisions right into the flow.

Now for the part that ties everything together — and this is where it gets genuinely interesting. Machine Learning can supercharge both RPA and BPA.

On their own, RPA and BPA are brilliant at predictable, rule-shaped work — and helpless the moment things get messy. Hand a plain RPA bot a document in a format it's never seen, or a decision that needs real judgement, and it stalls. That's exactly the gap ML fills. Drop an ML model into the workflow and suddenly the automation can classify an unfamiliar document, detect anomalies — like an invoice for nine hundred and ninety-nine thousand dollars that should probably get a human's attention — and make smarter routing decisions. The textbook's final example does precisely this: ML classifies each incoming document and flags the weird ones, while traditional RPA handles the structured data extraction and BPA routes it to the right queue. The pattern is — let ML handle the judgement and the messiness, and let rule-based automation handle the reliable, repetitive plumbing. Together they automate far more than either could alone.

Let's land this. Here are your takeaways for the exam and for real life.

One. AI is the broad field of intelligent systems; it may or may not learn. ML is the subset that learns from data. AI contains ML, not the other way around.

Two. RPA is task-level: a bot simulating a user across application screens. BPA is process-level: orchestrating a whole multi-system, multi-approval workflow.

Three. The practical rule of thumb. Reach for RPA when you've got repetitive, rule-based tasks with clear screen interactions. Reach for BPA when you've got a complex process spanning several systems and people. And add ML when you're facing unstructured data, decisions that need judgement, or a need for the system to adapt over time.

And four. The strategy. Start simple. Get the clear, rule-based automation working first, then layer ML in at the decision points where it actually earns its keep. Don't reach for the most complex tool just because it's the shiniest.

That's the map. Four terms, two scales, one big idea — match the technology to the shape of the problem. Next session we'll go deeper into how ML models are actually trained. See you then.

