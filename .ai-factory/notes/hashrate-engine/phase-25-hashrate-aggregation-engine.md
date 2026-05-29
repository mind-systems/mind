# Phase 25 — Hashrate Aggregation Engine

The Hashrate Aggregation Engine is the economic interpretation layer of the Bio-Proof-of-Brain mining architecture. Its responsibility is to transform isolated contributor outputs into a single normalized mining influence value representing the user’s effective hashrate for a given epoch.

All previous systems operate in the domain of biology, trust, adaptation, and interpretation.

The Hashrate Aggregation Engine is the first layer that operates explicitly in the domain of protocol economics.

This distinction is critical.

The Contributor Engine answers:

* what kinds of meaningful biological regulation occurred,
* how strong those signals were,
* how trustworthy those signals appear.

The Hashrate Aggregation Engine answers:

* how much mining influence those biological signals should produce within the economy of the network.

Architecturally, the aggregation engine sits directly between contributor scoring and reward distribution.

```text id="f83lpi"
Contributor Engine
    ↓
Contributor Results
    ↓
Hashrate Aggregation Engine
    ↓
HashrateEpochSnapshot
    ↓
Reward Epoch Engine
```

The engine consumes:

* contributor outputs,
* contributor weights,
* protocol difficulty configuration,
* trust modifiers,
* network policy configuration.

It produces:

* a deterministic hashrate snapshot for the epoch.

The architecture intentionally separates contributor computation from economic aggregation.

This separation is one of the most important long-term protocol decisions in the system.

Biological interpretation and economic policy evolve independently.

For example:

* the protocol may later rebalance contributor influence,
* introduce seasonal mining modifiers,
* temporarily promote recovery-focused mining,
* reduce influence from over-optimized contributor classes,
* introduce anti-centralization pressure,
* implement dynamic difficulty systems.

None of those changes should require modifying contributor implementations themselves.

The aggregation layer therefore becomes the canonical boundary between:

* biological meaning,
* economic influence.

The engine introduces the concept of effective hashrate.

Effective hashrate is not a direct measurement of biological output.

It is an economically weighted representation of trustworthy biological contribution within the network.

This distinction is extremely important.

The protocol intentionally avoids a simplistic:

* “more alpha equals more tokens”
* “higher HRV equals higher rewards”

model.

Instead, effective hashrate emerges from:

* contributor composition,
* confidence weighting,
* profile-relative interpretation,
* trust adjustments,
* protocol-level economic policy.

The aggregation engine is therefore responsible for transforming multidimensional physiological interpretation into a normalized mining primitive usable by emission systems.

The engine operates entirely on discrete epochs.

It never processes realtime streams directly.

Each aggregation cycle consumes the finalized contributor outputs for one Reduction Epoch and produces exactly one deterministic hashrate snapshot.

The engine must remain deterministic and replayable.

Given:

* identical contributor outputs,
* identical aggregation configuration,
* identical protocol policy,
* identical trust modifiers,

the resulting hashrate snapshot must always be identical.

Replayability is mandatory because the aggregation engine directly affects economic distribution.

Future protocol upgrades may require:

* rescoring historical epochs,
* recalculating rewards,
* auditing contributor economics,
* replaying anti-fraud decisions,
* rebuilding historical emission state.

The engine therefore must never contain:

* nondeterministic logic,
* hidden mutable state,
* randomization,
* uncontrolled external dependencies.

The engine introduces weighted aggregation.

Contributors are intentionally multidimensional and independent.

However, not all contributors necessarily carry equal economic significance.

For example:

* sustained focus may initially be weighted heavily,
* emotional regulation may be experimental,
* recovery contributors may be temporarily boosted,
* certain contributor classes may later be deprecated.

The aggregation engine therefore applies configurable protocol-level weighting.

The weighting system must remain externalized and versioned.

Weights must never be hardcoded inside contributor implementations.

The protocol must support future governance-driven economic tuning without requiring contributor rewrites.

Aggregation combines:

* contributor score,
* contributor confidence,
* contributor weight,
* trust modifiers.

The engine intentionally distinguishes:

* raw contributor output,
* economically effective contributor influence.

This distinction becomes increasingly important as anti-fraud and trust systems mature.

For example:

* a contributor may produce a strong raw score,
* but reduced quality confidence,
* elevated fraud suspicion,
* weak profile certainty.

The aggregation engine therefore computes economically adjusted influence rather than blindly summing contributor outputs.

The engine introduces protocol-level difficulty adjustment.

Pure biological scoring is insufficient for a stable mining economy because:

* network participation changes,
* user populations evolve,
* optimization strategies emerge,
* contributor distributions drift,
* hardware access expands.

Without difficulty adjustment, token emission becomes economically unstable.

The aggregation engine therefore applies network-level scaling policy.

Difficulty policy is intentionally separated from emission scheduling.

This distinction is critical.

Difficulty determines:

* relative mining influence.

Emission determines:

* total reward supply.

Keeping these systems independent allows:

* stable economic tuning,
* flexible participation balancing,
* future governance controls,
* adaptive scaling models.

The engine may eventually support:

* participation-adjusted scaling,
* contributor saturation damping,
* anti-centralization pressure,
* diminishing returns,
* protocol health balancing.

Phase 25 establishes the architectural foundation for those systems without implementing complex dynamic economics yet.

The aggregation engine also becomes the first major consumer of fraud-risk weighting.

The protocol intentionally avoids binary fraud invalidation in most situations.

Instead, mining influence degrades probabilistically under elevated suspicion.

For example:

* minor anomalies may slightly reduce effective influence,
* repeated suspicious patterns may suppress contributor confidence,
* high-risk behavioral signatures may sharply reduce effective hashrate,
* trusted long-term users may retain stronger confidence multipliers.

The aggregation layer becomes the economic application point of trust.

This separation is essential because:

* Anti-Fraud evaluates behavior,
* Aggregation applies economic consequences.

The Anti-Fraud Engine itself must never directly modify rewards.

That responsibility belongs here.

The engine produces a canonical epoch snapshot object.

```ts id="w2e55r"
interface HashrateEpochSnapshot {
  sessionId: string;

  userId: string;

  epochStartedAt: Date;

  epochEndedAt: Date;

  contributors: ContributorAggregationResult[];

  rawHashrate: number;

  effectiveHashrate: number;

  qualityScore: number;

  fraudRiskScore: number;

  aggregationVersion: number;

  metadata?: Record<string, unknown>;
}
```

This snapshot becomes one of the most important economic records in the entire protocol.

It represents the finalized mining interpretation of one epoch of human biological activity.

All downstream economic systems depend on it.

The snapshot must therefore remain:

* immutable,
* replayable,
* auditable,
* versioned,
* attributable.

The architecture intentionally preserves intermediate contributor data inside the snapshot.

The protocol must never reduce historical epochs into opaque final numbers only.

Future systems may require:

* contributor-level audits,
* reward dispute analysis,
* scientific reevaluation,
* fraud investigation,
* contributor rebalance replay.

The snapshot therefore preserves:

* contributor outputs,
* trust context,
* aggregation parameters,
* effective scaling.

The engine must support future aggregation-policy evolution.

Different future mining modes may require fundamentally different aggregation logic.

For example:

* meditation mining may reward stability heavily,
* recovery mining may emphasize improvement velocity,
* competitive mining modes may normalize globally,
* cooperative modes may reward consistency over intensity.

The architecture must therefore treat aggregation policy as modular and versioned rather than permanent protocol law.

The aggregation engine also becomes the primary boundary between physiology and token economics.

Everything before this layer is fundamentally about:

* biology,
* regulation,
* adaptation,
* trust.

Everything after this layer is fundamentally about:

* emission,
* distribution,
* settlement,
* scarcity,
* protocol economics.

This boundary is extremely important architecturally because it prevents economic logic from contaminating scientific and physiological systems upstream.

The aggregation engine ultimately transforms:

* multidimensional human biological regulation

into:

* deterministic protocol mining influence.

That transformation becomes the canonical economic substrate upon which the rest of the Bio-Proof-of-Brain economy operates.
