# Phase 21 — Quality Engine

The Quality Engine is the first trust-oriented computational layer in the Bio-Proof-of-Brain mining architecture. Its responsibility is to evaluate the reliability, integrity, and physiological plausibility of reduced biometric state before any reward-related scoring occurs.

The Quality Engine exists because biometric telemetry is inherently noisy, partially unreliable, and vulnerable to both accidental corruption and intentional manipulation. EEG streams contain artifacts. Heart-rate streams may freeze or desynchronize. Mobile devices may buffer packets irregularly. Users may wear sensors incorrectly. Future attackers may attempt replay attacks or synthetic signal generation.

The system must therefore distinguish between:

* high-quality biological state,
* low-quality but honest telemetry,
* suspicious or impossible telemetry.

This distinction is the responsibility of the Quality Engine.

The Quality Engine does not determine rewards, does not compute hashrate, does not apply fraud penalties, and does not make economic decisions. It produces only one thing: a structured reliability assessment of the current physiological epoch.

Architecturally, the Quality Engine sits directly above the Signal Reduction Pipeline.

```text id="vhp2lm"
raw telemetry
    ↓
Signal Reduction Pipeline
    ↓
ReducedBioState
    ↓
Quality Engine
    ↓
SignalQualityReport
    ↓
AntiFraud Engine
    ↓
Contributor Engine
```

The engine operates exclusively on reduced epoch states. It never reads realtime transport streams directly and never performs raw packet reconstruction. All temporal alignment, smoothing, interpolation, and reducer logic have already been completed by the Signal Reduction Pipeline.

This separation is strict and must never be violated.

The Quality Engine evaluates only normalized epoch state.

The engine exists because future contributors and economic systems must never independently decide whether telemetry is trustworthy. Trust evaluation must be centralized. Otherwise every contributor would implement its own artifact detection, timing validation, and plausibility heuristics, leading to inconsistent scoring behavior and impossible replay guarantees.

The Quality Engine becomes the canonical source of signal integrity throughout the entire mining architecture.

Every later system consumes its output.

The engine processes one Reduction Epoch at a time.

The input is a fully materialized `ReducedBioState`.

```ts id="ix81lp"
interface ReducedBioState {
  epochStartedAt: Date;
  epochEndedAt: Date;

  eeg?: ReducedEegState;
  cardio?: ReducedCardioState;
  emotions?: ReducedEmotionState;
}
```

The engine evaluates the epoch through a set of isolated quality checks. Each quality check represents a single physiological or transport integrity hypothesis.

Examples include:

* EEG flatline detection,
* impossible HRV transitions,
* synthetic timing regularity,
* biologically implausible coherence,
* repeated waveform structures,
* artifact saturation.

A quality check does not assign rewards and does not reject epochs directly. It only evaluates confidence.

Each quality check produces a normalized reliability score and optional diagnostic flags.

The Quality Engine then aggregates all check outputs into a unified epoch-level quality assessment.

This output becomes the canonical trust primitive for all downstream systems.

The engine introduces the concept of physiological confidence.

Confidence is not binary.

A signal may be:

* highly trustworthy,
* partially degraded,
* noisy but usable,
* suspicious,
* unusable.

The architecture intentionally avoids hard-valid/invalid decisions inside the Quality Engine because physiological data naturally contains instability and ambiguity.

Instead, the engine produces probabilistic trust estimates.

This allows downstream systems to:

* reduce contributor influence,
* suppress rewards,
* trigger anti-fraud review,
* ignore unstable signals,
* adapt weighting dynamically.

Without introducing brittle rejection thresholds.

The Quality Engine is intentionally deterministic.

Given:

* identical reduced epoch state,
* identical engine configuration,
* identical check versions,

the output must always be identical.

No stochastic logic, randomization, or ML inference may exist in Phase 21.

Replayability is a hard requirement because future reward audits depend on reproducible trust scoring.

Each quality check implements a shared interface.

```ts id="m15m8y"
interface QualityCheck<
  TState = ReducedBioState
> {
  id: string;

  version: number;

  evaluate(
    state: TState,
  ): Promise<QualityCheckResult>;
}
```

The `version` field is mandatory.

Changing check logic changes historical trust interpretation. Therefore every modification to quality evaluation math must increment the check version.

Historical quality reports must preserve:

* check identifiers,
* versions,
* scores,
* emitted flags.

The engine must support partial execution failure.

A failing quality check must never terminate epoch processing.

If a check crashes:

* the failure is logged,
* the failed check result is omitted,
* the epoch continues processing,
* downstream systems receive partial quality information.

One unstable check must never block mining infrastructure.

The initial implementation focuses on four major trust domains:

* EEG quality,
* cardio quality,
* timing quality,
* cross-signal coherence.

EEG quality checks are especially important because EEG is both noisy and highly exploitable for future fraud attempts.

The engine must detect:

* band flatlining,
* impossible amplitude jumps,
* clipping,
* frozen entropy,
* unrealistically stable alpha persistence,
* mathematically repeated structures,
* abrupt non-biological transitions.

The purpose is not to perfectly detect fraud. The purpose is to quantify confidence degradation.

The cardio domain evaluates whether physiological cardiac behavior appears biologically plausible.

The engine analyzes:

* HRV continuity,
* rhythm instability,
* frozen heart-rate structures,
* impossible recovery slopes,
* statistically synthetic variance patterns.

The system must tolerate naturally unusual physiology. Elite athletes, meditation practitioners, and exhausted users may produce atypical cardiac metrics.

The engine therefore evaluates plausibility probabilistically rather than through hard thresholds.

Timing quality checks evaluate the transport characteristics of incoming telemetry.

This is critical because synthetic systems often produce unrealistically perfect cadence.

Human telemetry pipelines naturally contain:

* jitter,
* burst delivery,
* micro-irregularity,
* mobile latency noise.

A synthetic stream often produces:

* perfectly uniform intervals,
* exact packet spacing,
* mechanically stable timing.

The Quality Engine therefore evaluates transport entropy as part of physiological confidence scoring.

Cross-signal coherence checks are among the most important future trust primitives.

Biological systems are correlated.

For example:

* deep relaxation usually correlates with reduced stress,
* elevated focus tends to alter EEG band distributions,
* HRV recovery trends correlate with emotional stabilization.

The engine therefore evaluates whether independent physiological domains evolve coherently.

Examples of incoherent state include:

* extremely high alpha with simultaneously maximal stress,
* impossible focus stability during heavy cardiac volatility,
* perfectly stable HRV during highly chaotic EEG transitions.

These checks do not prove fraud independently. They only reduce confidence.

The Quality Engine produces a unified epoch report.

```ts id="dn7v0j"
interface SignalQualityReport {
  epochStartedAt: Date;

  epochEndedAt: Date;

  overallScore: number;

  checks: QualityCheckResult[];

  flags: QualityFlag[];
}
```

The `overallScore` represents aggregate physiological trustworthiness for the epoch.

The aggregation model must remain configurable because different future mining modes may prioritize different signal domains.

For example:

* meditation mining may weight EEG quality heavily,
* recovery mining may prioritize cardio coherence,
* focus training may emphasize emotional classifier stability.

The engine must therefore avoid hardcoded weighting assumptions.

Quality flags are structured diagnostics intended for:

* AntiFraud Engine,
* contributor suppression,
* observability,
* debugging,
* future coaching systems.

Flags are never user-facing in raw form.

A future coaching layer may translate them into human-readable feedback, but the Quality Engine itself is infrastructure-level only.

The engine must remain computationally lightweight.

Phase 21 explicitly forbids:

* neural networks,
* online ML inference,
* GPU workloads,
* long historical scans,
* population-wide analysis.

The engine operates only on:

* the current epoch,
* limited local temporal context if required.

Longitudinal behavioral analysis belongs to the Anti-Fraud Engine introduced later.

The Quality Engine is not an anti-cheat system.

It is a signal integrity system.

This distinction is critical.

Quality answers:
“Can this physiological epoch be trusted?”

Anti-fraud answers:
“Does this user behavior indicate manipulation?”

Those are separate architectural responsibilities and must never be merged.

The Quality Engine becomes one of the foundational primitives of the entire mining economy because every future reward ultimately depends on the system’s ability to estimate how trustworthy a physiological state actually is.
