# Phase 27 — Emission Scheduler

The Emission Scheduler is the monetary policy layer of the Bio-Proof-of-Brain mining architecture. Its responsibility is to determine how many tokens the protocol is allowed to emit over time and how emission evolves as the network matures.

All previous systems determine:

* what biological activity occurred,
* how trustworthy it was,
* how meaningful it was,
* how rewards should be distributed between participants.

The Emission Scheduler answers a fundamentally different question:

“How many tokens should exist at this point in the life of the protocol?”

This distinction is extremely important.

The Reward Epoch Engine allocates rewards between users.

The Emission Scheduler controls total monetary expansion.

These responsibilities must remain completely independent.

Architecturally, the Emission Scheduler sits above reward settlement policy and below protocol governance.

```text id="v12d4r"
Protocol Governance
    ↓
Emission Scheduler
    ↓
Reward Epoch Engine
    ↓
Reward Allocation
```

The scheduler does not know anything about:

* EEG,
* HRV,
* contributors,
* quality scoring,
* fraud detection,
* users,
* sessions,
* wallets.

Its domain is purely monetary.

This separation is one of the most important architectural decisions in the protocol because monetary policy must remain stable even as biological interpretation evolves.

The protocol may eventually:

* redesign contributors,
* add new sensors,
* improve fraud systems,
* rebalance mining weights,
* introduce new mining modes.

None of those changes should alter the emission curve itself.

Likewise:

* emission halvings,
* supply limits,
* treasury allocation,
* ecosystem reserves

must not require modifications to physiological systems.

The Emission Scheduler therefore becomes the canonical monetary policy engine of the protocol.

The scheduler introduces deterministic scarcity.

Without scarcity, mining has no economic meaning.

Without bounded emission, biological mining collapses into inflationary extraction.

The scheduler therefore defines:

* total supply,
* emission velocity,
* emission decay,
* reward issuance schedule,
* long-term scarcity dynamics.

The architecture intentionally adopts a Bitcoin-inspired emission philosophy.

Emission decreases predictably over time.

This creates:

* long-term scarcity,
* early participation incentives,
* bounded monetary expansion,
* predictable economic expectations.

However, the protocol does not copy Bitcoin mechanically.

The mining environment is fundamentally different.

Bitcoin measures:

* computational work.

Bio-Proof-of-Brain measures:

* human biological regulation.

Human participation dynamics evolve differently from hardware competition.

The protocol therefore compresses emission into a shorter lifecycle and introduces adaptive participation balancing.

The initial monetary model targets:

* fixed maximum supply,
* deterministic emission decay,
* multi-year network lifecycle,
* gradual reduction in epoch rewards.

The scheduler must remain deterministic.

Given:

* identical block height,
* identical emission configuration,
* identical governance state,

the scheduler must always produce identical outputs.

Replayability is mandatory because every historical reward allocation depends on emission state.

Future replay systems must be capable of reconstructing:

* historical supply,
* historical reward pools,
* historical allocation conditions,
* historical scarcity state.

The scheduler therefore behaves as deterministic monetary state-transition logic.

The engine introduces emission epochs.

An emission epoch defines the reward budget available for settlement during a specific protocol interval.

For example:

```text id="8zsl1x"
block range
    →
emission budget
    →
reward pool
```

The scheduler itself does not distribute rewards.

It only defines the total reward quantity available for allocation.

The Reward Epoch Engine later distributes this budget proportionally across participants.

This separation is extremely important.

The scheduler controls:

* supply creation.

The Reward Engine controls:

* supply distribution.

Keeping these systems independent allows the protocol to evolve economically without destabilizing monetary policy.

The scheduler introduces the concept of halving intervals.

Over time, emission decreases according to a deterministic decay schedule.

This gradually shifts the protocol from:

* high-growth participation incentives

toward:

* scarcity-driven long-term economics.

The exact decay function must remain configurable.

The architecture must support:

* fixed halvings,
* smooth exponential decay,
* adaptive emission curves,
* governance-controlled adjustment windows.

However, all emission changes must remain:

* transparent,
* deterministic,
* versioned,
* replayable.

The scheduler also introduces supply accounting.

The protocol must always be able to compute:

* total emitted supply,
* remaining supply,
* current emission velocity,
* projected future issuance,
* historical inflation state.

These values become protocol-level primitives used by:

* governance,
* analytics,
* treasury systems,
* ecosystem planning,
* staking systems,
* future exchange integrations.

The Emission Scheduler intentionally avoids dependence on realtime user activity.

This is critical.

Mining participation fluctuates continuously.

Monetary policy must remain stable independently from short-term behavioral volatility.

Otherwise:

* reward instability emerges,
* inflation becomes unpredictable,
* protocol expectations collapse.

Instead, participation influences:

* reward competition,
* effective mining difficulty,
* per-user allocation.

Participation does not directly alter:

* total emission supply.

This separation mirrors traditional proof-of-work economics and is essential for long-term predictability.

The scheduler does, however, support protocol-level difficulty ceilings.

This is one of the major architectural deviations from traditional proof-of-work systems.

In hardware mining systems, dominant operators can scale computational power nearly without biological constraint.

In Bio-Proof-of-Brain systems, the protocol intentionally limits infinite optimization behavior.

Without balancing mechanisms:

* industrialized participation,
* optimized farms,
* excessive session grinding

could destabilize reward fairness.

The scheduler therefore supports future adaptive balancing mechanisms such as:

* effective hashrate ceilings,
* participation normalization,
* diminishing reward efficiency,
* reward floor systems,
* anti-centralization scaling.

However, these mechanisms must remain downstream from supply emission itself.

The scheduler defines monetary issuance.

Difficulty systems define competitive allocation pressure.

Those are separate concerns.

The Emission Scheduler produces canonical emission state objects.

```ts id="xos29r"
interface EmissionState {
  currentBlock: number;

  totalSupply: string;

  emittedSupply: string;

  remainingSupply: string;

  currentEpochReward: string;

  nextHalvingBlock: number;

  emissionVersion: number;
}
```

This object becomes one of the foundational monetary records of the protocol.

All economic systems downstream depend on it.

The scheduler must remain fully auditable.

The protocol must always be capable of explaining:

* why a reward pool had a certain size,
* why supply changed,
* which emission rules applied,
* which halving interval was active,
* how future emission is projected.

Opaque monetary policy is unacceptable in a deterministic economic protocol.

The architecture intentionally avoids discretionary monetary issuance.

No subsystem should be capable of:

* arbitrarily minting supply,
* bypassing emission policy,
* inflating rewards dynamically,
* overriding scarcity guarantees.

All emission must flow through the scheduler.

This makes the scheduler one of the highest-trust systems in the entire architecture.

The scheduler must also tolerate future governance evolution.

The protocol may later introduce:

* treasury allocation,
* ecosystem grants,
* staking emissions,
* research funding pools,
* validator incentives,
* protocol-owned liquidity reserves.

The architecture must therefore support multiple emission destinations while preserving deterministic total supply accounting.

The scheduler itself remains neutral regarding distribution purpose.

It only defines:

* how much supply becomes available,
* when it becomes available,
* under which emission rules.

The Emission Scheduler ultimately transforms:

* protocol time

into:

* deterministic monetary scarcity.

That scarcity becomes the economic foundation upon which the entire Bio-Proof-of-Brain ecosystem operates.
