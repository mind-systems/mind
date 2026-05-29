# Phase 26 — Reward Epoch Engine

The Reward Epoch Engine is the settlement layer of the Bio-Proof-of-Brain mining architecture. Its responsibility is to transform effective user hashrate into actual reward allocation within the protocol economy.

All previous layers exist to determine:

* what biological activity occurred,
* how trustworthy it was,
* how meaningful it was,
* how much economic mining influence it should produce.

The Reward Epoch Engine answers the next question:

“How should protocol rewards be distributed across the network for this epoch?”

This is the first layer where individual mining influence becomes actual economic allocation.

Architecturally, the Reward Epoch Engine sits between hashrate aggregation and blockchain settlement.

```text id="yq9f5f"
Hashrate Aggregation Engine
    ↓
HashrateEpochSnapshots
    ↓
Reward Epoch Engine
    ↓
RewardLedger
    ↓
Oracle Settlement Layer
    ↓
Blockchain
```

The engine consumes:

* finalized hashrate epoch snapshots,
* emission schedule outputs,
* network participation state,
* protocol reward policy.

It produces:

* deterministic reward allocations,
* claimable balances,
* immutable reward settlement records.

The Reward Epoch Engine does not compute biology, does not evaluate fraud, does not process telemetry, and does not interact directly with realtime streams.

Its domain is strictly economic settlement.

This separation is one of the most important architectural boundaries in the protocol.

The engine intentionally operates on finalized epoch snapshots only.

The snapshot produced by the Hashrate Aggregation Engine represents the complete economic interpretation of a user’s physiological activity for a specific epoch.

The Reward Epoch Engine treats that snapshot as immutable input.

This is critical because reward systems must never reinterpret biology directly.

Otherwise:

* replay becomes impossible,
* audits become unstable,
* economic policy leaks into scoring systems,
* reward calculations become nondeterministic.

The Reward Epoch Engine therefore acts as a pure settlement layer.

The engine introduces the concept of network-relative mining allocation.

A user’s reward is not determined solely by their own effective hashrate.

It is determined relative to the total effective hashrate of all active participants during the reward epoch.

This mirrors traditional proof-of-work economics while replacing computational work with biological regulation work.

The protocol intentionally preserves this relative-share model because it creates:

* scarcity pressure,
* participation balancing,
* difficulty responsiveness,
* bounded emission.

The engine therefore computes reward distribution proportionally.

For a given epoch:

```text id="5xj4mo"
user reward =
  epoch reward pool
  ×
  (user effective hashrate / total network effective hashrate)
```

This formula represents one of the core economic primitives of the entire protocol.

However, the architecture intentionally avoids coupling this formula directly to contributor logic or emission scheduling.

The Reward Epoch Engine is responsible only for allocation mechanics.

Emission policy is handled separately by the Emission Scheduler introduced later.

This separation is critical.

The protocol must be able to:

* change emission curves,
* alter halving schedules,
* introduce treasury allocation,
* add staking reserves,
* modify ecosystem distribution

without rewriting reward allocation infrastructure.

Likewise:

* contributor redesign,
* fraud-policy changes,
* quality adjustments,
* aggregation modifications

must not require rewriting settlement mechanics.

The Reward Epoch Engine therefore becomes the canonical bridge between:

* mining influence,
* token allocation.

The engine introduces the concept of Reward Epochs.

Reward Epochs are protocol settlement intervals over which mining rewards are allocated.

Reward epochs are intentionally distinct from Reduction Epochs.

Reduction Epochs exist for physiological processing.

Reward Epochs exist for economic settlement.

Initially, the two may share the same duration for simplicity, but the architecture must not assume they are permanently coupled.

Future protocol evolution may require:

* finer physiological epochs,
* coarser reward settlement windows,
* delayed settlement batching,
* probabilistic smoothing,
* anti-volatility reward buffering.

The architecture must therefore preserve conceptual separation between:

* biological epochs,
* settlement epochs.

The Reward Epoch Engine must remain fully replayable.

Replayability is one of the most important economic guarantees in the entire system.

Given:

* identical hashrate snapshots,
* identical reward policy,
* identical emission schedule outputs,
* identical epoch boundaries,

the reward allocations must always be identical.

Replayability is required for:

* fraud review,
* economic auditing,
* protocol governance,
* contributor rebalance replay,
* historical settlement reconstruction,
* dispute investigation,
* future scientific reevaluation.

The protocol therefore treats reward allocation as deterministic economic state transition logic.

The engine introduces immutable reward settlement records.

Every reward allocation must produce a permanent settlement artifact.

For example:

```ts id="fsm5zt"
interface RewardEpochSettlement {
  rewardEpochId: string;

  epochStartedAt: Date;

  epochEndedAt: Date;

  totalRewardPool: string;

  totalNetworkHashrate: number;

  participants: RewardParticipantResult[];

  settlementVersion: number;
}
```

Each participant allocation must remain individually attributable.

The protocol must always be able to answer:

* why a user received a reward,
* which hashrate snapshot produced it,
* which aggregation version was used,
* which emission policy applied,
* which fraud modifiers influenced settlement.

Opaque settlement is unacceptable.

The engine therefore preserves full attribution chains.

The Reward Epoch Engine also introduces settlement finality boundaries.

Biological scoring systems may continue evolving indefinitely.

However, economic settlement requires eventual finalization.

The architecture therefore introduces the concept of delayed economic finality.

An epoch may initially remain:

* provisional,
* reviewable,
* replayable.

During this window:

* fraud systems may reevaluate behavior,
* delayed telemetry anomalies may surface,
* protocol bugs may require replay,
* suspicious patterns may escalate.

Only after the review window expires does settlement become finalized for blockchain claimability.

This delayed-finality model becomes extremely important later because:

* biometric systems are probabilistic,
* fraud detection improves over time,
* replay attacks may surface retroactively.

The protocol intentionally avoids irreversible instant settlement.

The Reward Epoch Engine also introduces reward floors and difficulty ceilings.

Pure proportional mining systems naturally concentrate rewards toward:

* optimized users,
* heavy participants,
* sophisticated operators.

Over time, this creates unhealthy economic centralization.

The architecture therefore supports future economic balancing primitives.

Examples include:

* minimum active-session rewards,
* diminishing-return curves,
* participation balancing,
* protocol-wide difficulty normalization,
* adaptive reward smoothing.

Phase 26 does not fully implement these systems yet, but the Reward Epoch Engine must support them architecturally.

The engine must also tolerate incomplete and degraded network conditions.

For example:

* delayed snapshots,
* temporarily missing users,
* replay recalculation,
* settlement retries,
* partial fraud reevaluation.

The engine therefore must operate idempotently.

Reprocessing the same settlement input must never duplicate reward allocation.

This becomes especially important later when replay infrastructure and delayed fraud review are introduced.

The Reward Epoch Engine writes into the canonical Reward Ledger.

The ledger represents the protocol’s off-chain economic state.

It tracks:

* accrued rewards,
* pending rewards,
* finalized rewards,
* claimed balances,
* settlement history.

The ledger becomes the authoritative economic source of truth before blockchain minting occurs.

Blockchain state is intentionally downstream from the ledger rather than upstream.

This is one of the protocol’s most important scalability decisions.

On-chain minting is expensive and operationally rigid.

Off-chain settlement allows:

* replay,
* delayed fraud review,
* economic rebalancing,
* efficient batching,
* rollback capability,
* protocol evolution.

The blockchain ultimately becomes the settlement export layer rather than the live economic computation layer.

The Reward Epoch Engine therefore acts as the true economic core of the mining protocol.

It transforms:

* deterministic biological mining influence

into:

* deterministic economic allocation state.

Everything after this layer concerns only settlement transport, token issuance, and blockchain synchronization.
