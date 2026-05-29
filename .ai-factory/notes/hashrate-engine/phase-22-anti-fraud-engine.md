# Phase 22 — Anti-Fraud Engine

The Anti-Fraud Engine is the first behavioral security layer in the Bio-Proof-of-Brain mining architecture. Its responsibility is to evaluate whether mining activity appears authentically human, biologically plausible over time, and economically legitimate within the context of the network.

The Anti-Fraud Engine exists because signal quality alone is insufficient to protect a biometric mining economy.

A telemetry stream may appear technically valid while still being fraudulent.

For example:

* replayed historical sessions may contain physiologically realistic EEG,
* synthetic generators may imitate plausible HRV variance,
* coordinated farms may rotate real hardware across wallets,
* attackers may optimize for contributor behavior without producing naturally evolving biological patterns.

The Quality Engine evaluates signal reliability inside a single epoch.

The Anti-Fraud Engine evaluates behavioral plausibility across time.

This distinction is absolute and must never be blurred.

Architecturally, the Anti-Fraud Engine sits above the Quality Engine and below reward scoring systems.

```text id="5vjlwm"
Signal Reduction Pipeline
    ↓
Quality Engine
    ↓
SignalQualityReport
    ↓
Anti-Fraud Engine
    ↓
FraudRiskReport
    ↓
Contributor Engine
```

The Anti-Fraud Engine consumes:

* reduced epoch states,
* quality reports,
* historical session activity,
* device associations,
* longitudinal behavior patterns,
* population-level statistical context.

Unlike the Quality Engine, the Anti-Fraud Engine is stateful.

Fraud detection requires historical memory.

The engine therefore maintains long-term behavioral context for:

* users,
* wallets,
* devices,
* sessions,
* mining patterns,
* reward trajectories.

The engine does not directly modify blockchain state and does not mint or revoke rewards. Instead, it produces a structured fraud-risk assessment that downstream systems may use to:

* reduce reward influence,
* suppress epochs,
* delay settlement,
* trigger cooldowns,
* require manual review,
* increase observation intensity.

The architecture intentionally avoids binary “fraud/not-fraud” decisions in most cases.

Human biological behavior is naturally irregular and highly diverse. Overly rigid anti-cheat systems inevitably punish legitimate users.

The Anti-Fraud Engine therefore operates probabilistically.

Its purpose is not perfect fraud elimination.

Its purpose is increasing the cost and complexity of exploitation while minimizing false positives.

The engine introduces the concept of longitudinal behavioral integrity.

Authentic biological activity evolves organically over time.

Real users:

* become fatigued,
* lose focus,
* improve gradually,
* vary day-to-day,
* exhibit circadian rhythms,
* produce imperfect session consistency,
* display non-deterministic physiological drift.

Synthetic systems tend toward:

* repeated structures,
* over-optimization,
* perfect regularity,
* statistically improbable stability,
* economically irrational behavior,
* population-level duplication patterns.

The Anti-Fraud Engine exists to model these differences.

The engine processes activity at multiple timescales simultaneously.

Short-term analysis examines:

* session continuity,
* epoch-to-epoch coherence,
* repeated local structures,
* reward exploitation patterns.

Long-term analysis examines:

* user evolution,
* device reuse,
* mining schedules,
* recovery behavior,
* longitudinal entropy,
* network relationships.

The engine must never depend on a single fraud heuristic.

No single detector is reliable enough in isolation.

Instead, the engine aggregates many weak behavioral signals into a probabilistic fraud-risk model.

This architecture is critical because future attackers will adapt to simplistic rules extremely quickly.

Every fraud detector implements a shared interface.

```ts id="mjlwm0"
interface FraudDetector {
  id: string;

  version: number;

  evaluate(
    ctx: FraudEvaluationContext,
  ): Promise<FraudDetectionResult>;
}
```

Each detector operates independently.

Detectors must never:

* mutate shared state,
* modify rewards,
* directly ban users,
* terminate sessions.

They only emit structured evidence.

The engine aggregates evidence into a unified fraud-risk assessment.

Detectors are intentionally isolated because fraud systems evolve continuously. New attack vectors must be introducible without rewriting the engine.

Versioning is mandatory.

Fraud interpretation changes over time. Historical investigations must preserve:

* detector versions,
* emitted evidence,
* confidence scores,
* risk contributions.

Replayability remains a hard architectural requirement.

The Anti-Fraud Engine introduces one of the most important concepts in the mining system: repeated-pattern analysis.

Human physiological systems contain natural entropy.

Even highly trained meditators do not reproduce identical alpha envelopes across sessions. Heart-rate variability evolves organically. Emotional classifiers drift naturally.

Synthetic systems, replay attacks, and optimization loops often introduce hidden repetition structures.

The engine therefore analyzes:

* waveform similarity,
* entropy stability,
* recurring transition structures,
* repeated variance envelopes,
* duplicated epoch sequences,
* temporal signature reuse.

The purpose is not exact duplicate detection alone.

Sophisticated attackers may introduce noise or partial perturbations.

The engine instead evaluates whether physiological evolution appears organically human over time.

Repeated-pattern analysis becomes one of the core long-term defenses of the mining economy.

The engine also evaluates population-level statistical anomalies.

Fraud often becomes visible only relative to other users.

Examples include:

* persistently impossible contributor performance,
* statistically dominant recovery curves,
* unrealistic session density,
* synchronized behavior across unrelated accounts,
* highly correlated reward trajectories.

The engine therefore requires controlled access to anonymized population statistics.

Population analysis must never expose raw user telemetry between users.

Only aggregated statistical context may be used.

The Anti-Fraud Engine also evaluates device relationships.

Future exploit attempts may include:

* one headset rotating across many wallets,
* coordinated mining farms,
* device sharing networks,
* synchronized session orchestration.

The engine therefore models:

* device-to-wallet graphs,
* session overlap,
* concurrent usage patterns,
* hardware reputation history,
* trust propagation.

The architecture intentionally treats devices as probabilistic trust anchors rather than absolute identity guarantees.

Trusted hardware may reduce fraud risk, but no consumer hardware should ever be treated as impossible to compromise.

The engine also evaluates behavioral economics.

Authentic human behavior contains natural constraints:

* sleep,
* fatigue,
* inconsistent motivation,
* recovery periods,
* attention degradation.

Attack systems often optimize exclusively for mining throughput.

The engine therefore analyzes:

* session density,
* circadian rhythm absence,
* uninterrupted mining behavior,
* unrealistic consistency,
* zero fatigue drift,
* reward-maximizing behavioral signatures.

These signals become increasingly important as the mining economy matures.

The Anti-Fraud Engine produces a unified fraud-risk assessment.

```ts id="ysc8al"
interface FraudRiskReport {
  epochStartedAt: Date;

  epochEndedAt: Date;

  overallRiskScore: number;

  detectors: FraudDetectionResult[];

  recommendedActions: FraudAction[];

  reasons: FraudReason[];
}
```

The engine itself does not execute actions.

This separation is critical.

Fraud evaluation and economic enforcement must remain independent systems.

The Anti-Fraud Engine only recommends responses.

Possible future actions include:

* reducing contributor confidence,
* suppressing rewards,
* introducing cooldown periods,
* delaying claim settlement,
* increasing observation sensitivity,
* escalating to manual review.

Economic policy remains outside the anti-fraud subsystem.

This separation allows the protocol to evolve economically without rewriting fraud infrastructure.

The Anti-Fraud Engine must remain explainable.

Black-box fraud systems are unacceptable in a replayable economic protocol.

Every risk contribution must remain attributable to:

* specific detectors,
* specific evidence,
* specific behavioral patterns.

Future auditing infrastructure depends on this property.

The engine must also tolerate uncertainty gracefully.

False positives are economically dangerous.

A legitimate user with unusual physiology must not be treated identically to an attacker.

The system therefore prefers gradual trust degradation over immediate punishment.

Suspicion accumulates probabilistically across time.

The architecture intentionally favors long-term observation over aggressive instant enforcement.

The Anti-Fraud Engine must remain computationally scalable.

Population analysis, graph analysis, and historical comparisons can become extremely expensive at scale.

Phase 22 therefore establishes only the architectural foundation:

* detector isolation,
* probabilistic scoring,
* replayability,
* evidence aggregation,
* longitudinal analysis boundaries.

Heavy ML systems, distributed graph analytics, and advanced clustering infrastructure are intentionally deferred to later phases.

The Anti-Fraud Engine is fundamentally an economic defense system.

Its role is not merely technical validation.

Its purpose is preserving the integrity of the mining economy by ensuring that long-term reward extraction remains more difficult to fake than to earn authentically through genuine biological training and engagement.
