Phase 22 — Anti-Fraud System (Session-Level Trust Degradation Engine)

The Anti-Fraud System is a session-scoped and near-real-time trust evaluation engine responsible for detecting anomalous, synthetic, or structurally inconsistent physiological behavior within active or recently active sessions. Its primary objective is to assess whether incoming biometric signals and derived module outputs are consistent with plausible human physiological dynamics within the context of the current session.

The system operates on short-to-medium temporal horizons and evaluates behavioral consistency across signal streams, module outputs, and eligibility transitions. It produces a continuous trust degradation signal that directly influences confidence weighting inside the Hashrate Aggregation Engine and Eligibility Engine.

Anti-Fraud is explicitly session-oriented. It does not maintain long-term identity modeling beyond what is necessary to stabilize session-level trust. Its outputs are ephemeral in nature, decaying over time if not reinforced by continued anomalous behavior. The system is designed to react to immediate or recent inconsistencies rather than build long-term behavioral profiles.

All outputs of Phase 22 are expressed as dynamic modifiers applied to real-time computation layers, including confidence scaling, eligibility damping, and module-level trust adjustment. These outputs are not persisted as identity attributes and are not used for long-term behavioral classification.

Phase 30 — Reputation System (Long-Term Identity Trust Model)

The Reputation System is a user-level persistent trust model that aggregates long-term behavioral consistency, physiological stability patterns, and historical reliability of signal production. Unlike Anti-Fraud, which operates on session-scoped dynamics, Reputation operates on extended temporal horizons spanning multiple sessions and long-term user trajectories.

Reputation is not a real-time system and does not influence immediate eligibility or reward computation directly. Instead, it functions as a slow-evolving structural attribute of a user that modulates system-level expectations about signal reliability, behavioral stability, and anomaly tolerance.

The Reputation System consumes outputs from Phase 22 (Anti-Fraud) as its primary input signal source. Specifically, it aggregates historical trust degradation events, anomaly frequency distributions, recovery patterns, and stability reinforcement signals across sessions. These are transformed into long-term reliability indicators that evolve gradually over time.

Reputation is maintained as a persistent state within the User State System and is versioned alongside system configuration changes. It acts as a slow-moving prior over user behavior rather than a reactive control mechanism.

Unlike Anti-Fraud, Reputation does not emit real-time modifiers. Instead, it influences baseline expectations used by upstream systems such as baseline calibration, confidence initialization, and anomaly threshold adaptation. It shapes how strict the system is toward a given user, rather than directly penalizing or filtering current behavior.

The key architectural principle is unidirectional dependency. Phase 22 (Anti-Fraud) feeds Phase 30 (Reputation), but Phase 30 must never feed back into real-time fraud detection logic. This prevents circular trust amplification loops and ensures that long-term reputation cannot be used to override immediate physiological anomalies.

Relationship Constraint (Critical Invariant)

Anti-Fraud and Reputation operate on the same underlying behavioral signals but at different temporal scales and with different system responsibilities.

Anti-Fraud is reactive, session-bound, and directly affects real-time computation.
Reputation is accumulative, identity-bound, and affects system priors only.

Reputation is strictly downstream of Anti-Fraud. Any attempt to use Reputation as an input to real-time fraud evaluation would violate system causality constraints and introduce feedback instability in trust modeling.

Behavioral Intelligence Layer (Unified Trust, Behavior & Adaptation System — Technical Specification)

The Behavioral Intelligence Layer is a consolidated meta-layer that unifies all non-realtime behavioral interpretation systems within the architecture. It merges three previously distinct domains: session-level fraud detection, long-term reputation modeling, and coaching-based behavioral adaptation. The purpose of this consolidation is to eliminate redundant signal interpretation pipelines while preserving strict separation between real-time economic computation and historical behavioral understanding.

This layer operates exclusively on persisted and versioned data produced by real-time systems. It does not consume raw biometric streams and does not participate in reward computation, eligibility evaluation, or hashrate aggregation. Its role is strictly interpretative and structural: it defines how the system understands user behavior over time and how that understanding influences non-economic system parameters.

The Behavioral Intelligence Layer is composed of three tightly coupled but hierarchically ordered subsystems. Each subsystem operates on a different temporal and semantic scale, but all share a unified data foundation derived from the User State System and the Session History Store.

At the lowest level of this layer is the Session Integrity Subsystem, which consolidates the responsibilities of the previous Anti-Fraud System. This subsystem evaluates short-term behavioral consistency within and across individual sessions. It detects anomalies, signal incoherence, and deviations from expected physiological patterns using deterministic evaluation functions applied over session-scoped data. Its outputs are continuous trust signals and anomaly events that are always time-bounded and decay over short horizons. These outputs directly influence real-time confidence modifiers in upstream computation layers but do not persist as identity-level attributes.

Above it sits the Long-Term Behavioral Model, which consolidates the previous Reputation System. This subsystem aggregates historical outputs of the Session Integrity Subsystem across extended time horizons to produce a stable, slow-evolving representation of user reliability. It does not evaluate raw behavior directly. Instead, it consumes structured outputs from session-level evaluation and transforms them into persistent trust priors. These priors influence system expectations such as baseline calibration sensitivity, anomaly tolerance thresholds, and confidence initialization parameters. The Long-Term Behavioral Model is strictly non-reactive and does not participate in real-time decision-making.

At the top of the layer is the Behavioral Adaptation Engine, which consolidates the previous Coaching System. This subsystem interprets long-term behavioral and physiological patterns to generate structured adaptation signals. It operates exclusively on aggregated, persisted data and produces deterministic adaptation vectors that guide user experience adjustments, session structuring, and behavioral guidance logic. While it may optionally incorporate insights from statistical or offline analytical models, all outputs must be translated into deterministic rule-based representations before being applied. This ensures that no opaque model directly influences user-facing behavioral changes.

The three subsystems are connected in a strict directional hierarchy. Session Integrity feeds Long-Term Behavioral Model. Long-Term Behavioral Model provides contextual priors to Behavioral Adaptation Engine. However, no subsystem is permitted to feed backward into real-time computation or economic systems. This enforces a strict separation between behavioral understanding and economic execution.

The Behavioral Intelligence Layer maintains a unified internal representation of user behavioral state. This representation includes session-level trust signals, long-term reputation scores, and adaptation vectors. However, each component operates on different temporal decay functions and update frequencies, ensuring that short-term anomalies do not immediately distort long-term identity, and long-term reputation does not suppress sensitivity to real-time anomalies.

All outputs of this layer are strictly advisory in nature with respect to economic systems. They influence parameters such as confidence weighting, baseline calibration, anomaly sensitivity, and coaching outputs, but never directly modify reward distribution, eligibility state, or hashrate computation. This preserves the deterministic integrity of the economic layer while allowing rich behavioral modeling above it.

The Behavioral Intelligence Layer is therefore the unified cognitive interpretation system of the platform. It transforms raw physiological history into structured understanding of user reliability, behavioral stability, and adaptation needs, while maintaining strict isolation from real-time economic execution.