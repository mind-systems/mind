# Mind System — Master Architecture (Single Source of Truth)

**Date:** 2026-05-26
**Status:** locked
**Source:** architectural synthesis across Phase 20–30 specs + WCSP model + 01-iteration refinements

---

## 1. System Overview

The system is divided into three independent planes:

**(A) Real-Time Execution Plane (WCSP Core)** — the only economic system. Produces hashrate, eligibility, and rewards in real time.

**(B) Persistent State Plane (Storage & Replay)** — historical record. Not authoritative for economic decisions.

**(C) Behavioral Intelligence Plane** — post-hoc interpretation. Transforms history into trust, reputation, and coaching signals.

Only Plane A affects money flow. Planes B and C are informational and adaptive only.

---

## 2. Real-Time Execution Plane (WCSP)

### 2.1 Purpose

WCSP (Weighted Continuous Selection Pool) is the only live computation system responsible for:

- computing hashrate
- determining eligibility
- maintaining active reward pool
- distributing reward shares

Operates entirely in-memory and in streaming mode. Never reads from persistent storage.

### 2.2 Internal Structure (WCSP = Phase 20–25 decomposition)

WCSP is internally composed of deterministic processing stages:

**Stage 1 — Signal Reduction Layer (Phase 20)**
Raw biometric streams normalized into unified signal space.
- Input: EEG, HRV raw RR, respiration, emotion streams
- Output: normalized continuous signal vector per user
- No economic logic.

**Stage 2 — Signal Quality Layer (Phase 21)**
Evaluates signal reliability: artifact detection, noise estimation, device stability.
- Output: quality coefficient ∈ [0..1]

**Stage 3 — Contributor Layer (Phase 24)**
Transforms signal vectors into feature-based scoring modules (HRV, EEG, breath, consistency).
- Output per contributor: score + quality-adjusted score

**Stage 4 — Hashrate Aggregation Layer (Phase 25)**
Weighted sum of contributors, normalized by quality, adjusted by streak/stability modifiers.
- Output: single scalar hashrate per user

**Stage 5 — Continuous Pool Engine (WCSP Core)**
Aggregates all active users, builds weighted selection pool, computes proportional reward shares continuously.
- Output: live reward allocation state

**Stage 6 — Emission Engine**
Follows emission schedule, applies halving logic, distributes reward per block/time tick.
- Output: reward deltas per user

### 2.3 WCSP Rule

WCSP is the **only authoritative economic system** — single source of truth for hashrate, eligibility, and reward distribution.

---

## 3. Persistent State Plane

### 3.1 Purpose

Stores historical system data for: replay, fraud analysis, coaching, debugging, audit.
**Not used for live computation.**

### 3.2 Core Storage Model

**`bio_session_samples`** — batched biometric samples.
- Each row = compressed batch (~25 samples)
- Each sample: `client_timestamp`, `sample_type`, payload
- Structure is a transport optimization only.

### 3.3 Temporal Model Rule

- `client_timestamp` = only valid time axis for analysis
- Batch structure = non-semantic (transport artifact)
- `server_timestamp` = operational metadata only

### 3.4 Reconstruction Layer (SignalWindowAssembler)

Used **only** in offline systems:
1. Flatten batches
2. Merge all samples
3. Sort by `client_timestamp`
4. Reconstruct physiological timeline

**Zero influence on WCSP.**

---

## 4. Behavioral Intelligence Plane

Interprets historical behavior. Does not affect real-time economy directly.

### 4.1 Session Integrity System (Anti-Fraud — Phase 22)

- Scope: session-level trust evaluation, anomaly detection, signal inconsistency
- Output: session trust score, anomaly events
- Influence: affects WCSP confidence weighting **only indirectly** via runtime flags; does NOT persist as identity

### 4.2 Long-Term Reputation System (Phase 30)

- Scope: multi-session aggregation of trust signals, identity-level reliability modeling
- Input: outputs of Session Integrity System (Phase 22)
- Output: reputation score (slow-moving prior)
- Influence: modifies system expectations (baseline sensitivity, thresholds); does NOT affect real-time decisions directly

### 4.3 Behavioral Adaptation Engine (Coaching — Phase 29)

- Scope: transforms long-term behavior into guidance signals
- Input: session history, reputation, aggregated physiological trends
- Output: adaptation vectors, coaching instructions
- Constraint: deterministic rule-based core; optional offline analytical augmentation (non-authoritative, must be translated into deterministic rules before application)

### 4.4 Unidirectional Dependency Rule

```
Session Integrity (Phase 22)
        ↓
Long-Term Reputation (Phase 30)
        ↓
Behavioral Adaptation (Phase 29)
```

No subsystem feeds backward into real-time computation or economic systems.
Reputation **never** feeds back into real-time fraud detection.

---

## 5. HRV Computation Authority Contract

- RR intervals originate in mobile layer (`IRrIntervalSource`, Note 27 in `mind_mobile`)
- Stored as raw `rr` sample_type in `bio_session_samples`
- **All HRV metrics (RMSSD, SDNN, pNN50, LF, HF, LF/HF) computed exclusively server-side** in HRV Stability Reducer (Phase 20)
- Device-computed HRV values (e.g. Neiry's kaplanIndex, stressIndex) are **ignored for economic logic**; may be stored for diagnostics only
- Forbidden: any downstream system (Aggregation, Eligibility, Anti-Fraud) using device-computed HRV as authoritative input

---

## 6. Global Data Flow

```
[ Mobile Sensors ]
        ↓
   neiry_kit (classifiers)
        ↓
[ Real-Time Biometric Stream ]
        ↓
┌──────────────────────────────────────────────────────┐
│  WCSP — Real-Time Execution Plane                    │
│                                                      │
│  Signal Reduction (Ph20)                             │
│        ↓                                             │
│  Signal Quality (Ph21)                               │
│        ↓                                             │
│  Contributors (Ph24)                                 │
│        ↓                                             │
│  Hashrate Aggregation (Ph25)                         │
│        ↓                                             │
│  Continuous Pool Engine                              │
│        ↓                                             │
│  Emission Engine (Ph27)                              │
│        ↓                                             │
│  Reward Distribution → RewardLedger                  │
│        ↓                                             │
│  Oracle Settlement (Ph28) → Blockchain               │
└──────────────────────────────────────────────────────┘
        ↓ (parallel persistence, non-blocking)
┌──────────────────────────────────────────────────────┐
│  Persistent State Plane                              │
│  bio_session_samples (batch storage)                 │
│        ↓                                             │
│  SignalWindowAssembler (offline reconstruction)      │
└──────────────────────────────────────────────────────┘
        ↓
┌──────────────────────────────────────────────────────┐
│  Behavioral Intelligence Plane                       │
│  ├─ Session Integrity / Anti-Fraud (Ph22)            │
│  ├─ Long-Term Reputation (Ph30)                      │
│  └─ Behavioral Adaptation / Coaching (Ph29)          │
└──────────────────────────────────────────────────────┘
```

---

## 7. Hard System Invariants

1. WCSP is the **only system** allowed to affect rewards
2. Batch storage (`bio_session_samples`) **never** influences WCSP computation
3. All historical reconstruction (SignalWindowAssembler) is offline only
4. `client_timestamp` is the only valid temporal axis for analysis
5. HRV is always computed server-side from raw RR intervals
6. Behavioral Intelligence cannot override real-time anomalies
7. Reputation cannot influence fraud detection decisions
8. Anti-Fraud and Reputation are unidirectional: Phase 22 → Phase 30, never reverse
9. Phase 23 (BioProfile) and Phase 26 (Reward Epoch) are internal WCSP layers, not standalone systems

---

## 8. Relationship to Existing Docs

| Document | Role |
|---|---|
| `reward-system-architecture.md` | Original concept; superseded by this doc for architecture decisions |
| `phase-20-signal-reduction-pipeline.md` | WCSP Stage 1 detailed spec |
| `phase-21-quality-engine.md` | WCSP Stage 2 detailed spec |
| `phase-22-anti-fraud-engine.md` | Behavioral Intelligence — Session Integrity |
| `phase-23-user-bioprofile-engine.md` | WCSP internal — BioProfile for personalization |
| `phase-24-contributor-engine.md` | WCSP Stage 3 detailed spec |
| `phase-25-hashrate-aggregation-engine.md` | WCSP Stage 4 detailed spec |
| `phase-26-reward-epoch-engine.md` | WCSP — Reward distribution mechanics |
| `phase-27-emission-scheduler.md` | WCSP — Monetary policy / emission schedule |
| `phase-28-oracle-settlement-layer.md` | WCSP — Blockchain settlement |
| `phase-29-coaching-*.md` | Behavioral Intelligence — Adaptation Engine |
| `phase-30-reputation-*.md` | Behavioral Intelligence — Long-Term Reputation |
| `weighted-continuous-selection-pool-*.md` | WCSP economic model full spec |
| `hrv-computation-authority-contract-*.md` | Cross-system HRV authority contract |
| `phase-20-temporal-truth-model-*.md` | Cross-system temporal model contract |
| `phase-22-anti-fraud-system-*.md` | Phase 22 refined spec (01-iteration) |
| `phase-29-coaching-system-*.md` | Phase 29 refined spec (01-iteration) |
