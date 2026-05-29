# Phase 28 — Oracle Settlement Layer

The Oracle Settlement Layer is the final trust bridge between off-chain biological mining computation and on-chain token state. Its responsibility is to take finalized economic decisions produced by the Reward Epoch Engine and Emission Scheduler, validate them against protocol rules, and commit them to the blockchain in a controlled, auditable, and failure-tolerant way.

At this point in the system, all biological interpretation, contributor scoring, aggregation logic, reward allocation, and emission calculation are already complete. Nothing in this layer computes or interprets biological data. The Oracle Settlement Layer exists purely to safely materialize already-decided economic state into on-chain minting and balance updates.

Architecturally, it is the last deterministic gate before irreversible blockchain state changes.

```text id="orcl1"
Signal → Reduction → Quality → AntiFraud → BioProfile → Contributors → Aggregation → Rewards → Emission → Oracle → Blockchain
```

The Oracle is not a single server or endpoint. It is a logically centralized role implemented as a fault-tolerant backend service cluster with strict determinism requirements. It consumes only canonical settlement artifacts produced earlier in the pipeline:

* RewardEpochSettlement objects from the Reward Epoch Engine
* EmissionState snapshots from the Emission Scheduler
* RewardLedger deltas from Postgres

It never consumes raw telemetry, contributor outputs, or intermediate biological state. Those inputs are considered invalid at this layer by design.

The Oracle Settlement Layer operates on batch windows rather than realtime streams. Typically, settlement is performed in hourly or epoch-aligned batches. This batching is a deliberate design choice to decouple biological realtime systems from blockchain throughput constraints.

Each settlement cycle begins with the Oracle collecting all finalized RewardEpochSettlement objects that have passed the protocol’s finality threshold. Finality here is not purely temporal; it is a composite state defined by:

* completion of fraud review window
* stabilization of contributor replay consistency
* absence of pending recalculation flags
* emission state final lock for the epoch
* ledger consistency verification

Only when all these conditions are satisfied can a settlement batch be constructed.

The Oracle then computes a deterministic batch payload that maps internal ledger balances to on-chain mint instructions. This process is strictly idempotent. Given the same input state, the Oracle must always produce the exact same output transaction set.

The resulting output is a sequence of batched smart contract calls:

* setClaim(user, amount)
* batchSetClaim(users[], amounts[])
* or Merkle-root-based claim distribution depending on scaling mode

The protocol intentionally supports multiple settlement strategies, but all strategies must be functionally equivalent in terms of final state correctness.

For early and mid-scale deployments, a batched `setClaim` model is used. For high-scale deployment, the system transitions to Merkle-based claims where the Oracle publishes a single root hash on-chain and users independently prove inclusion.

This scalability evolution is a critical property of the architecture: the Oracle layer is designed to evolve without changing upstream systems.

Before any transaction is signed, the Oracle performs a full consistency verification pass. This verification ensures:

* Sum of all user allocations equals total emitted reward for the batch
* No duplication of reward epochs across multiple settlement batches
* No missing RewardEpochSettlement entries within finalized windows
* Emission constraints are not violated
* Ledger deltas match aggregated settlement outputs

If any inconsistency is detected, the entire batch is rejected and flagged for replay. The Oracle is allowed to halt settlement but is not allowed to “repair” state. Repair is strictly the responsibility of upstream replay systems.

Once verified, the Oracle constructs blockchain transactions and submits them through a controlled signing pipeline. Private keys are never exposed directly to application logic. Instead, signing is performed through a dedicated secure execution environment with restricted API surface area, ideally isolated via HSM or equivalent secure enclave system.

Every transaction emitted by the Oracle includes full traceability metadata:

* rewardEpochId range
* emissionState version
* aggregationVersion
* ledger snapshot hash

This ensures that every on-chain state change can be traced back deterministically to a specific internal computation state.

The Oracle also maintains a persistent Settlement Journal. This journal records every attempt to settle, including successful, failed, and partially failed batches. The journal is append-only and becomes the canonical forensic record for protocol-level auditing.

Each journal entry includes:

* input snapshot hashes
* computed batch hash
* transaction payload hash
* blockchain transaction IDs
* failure reason (if any)
* retry count
* final resolution state

This allows the entire settlement system to be replayed or audited independently of both the database and the blockchain.

The Oracle Settlement Layer also introduces retry discipline. Settlement is not allowed to be retried arbitrarily. Instead, retries follow strict rules:

* identical input state must produce identical transaction payloads
* any divergence in output indicates a deterministic violation and forces rollback to replay mode
* repeated failures escalate to manual or governance intervention state

This prevents silent corruption of monetary state.

A key architectural constraint is that the Oracle is not allowed to modify economic outcomes. It cannot adjust rewards, reweight users, or reinterpret biological data. It is strictly a deterministic exporter of precomputed economic state.

This makes the Oracle fundamentally different from traditional “backend payout systems.” It is not a business logic layer. It is a cryptographic settlement compiler.

As the system scales, the Oracle can operate in multiple execution modes:

In direct mode, it signs and submits transactions immediately per batch. This is suitable for early-stage deployments.

In queued mode, it aggregates multiple settlement batches and submits them as a single optimized transaction set to reduce gas costs.

In Merkle mode, it publishes root commitments and delegates claim execution entirely to users, minimizing Oracle-side gas usage and shifting verification burden to clients.

All modes are equivalent in correctness but differ in economic efficiency.

The Oracle Settlement Layer ultimately represents the final transformation step in the entire Bio-Proof-of-Brain system. It converts deterministic human biological computation into irreversible blockchain state.

It is the point where the system stops being a model of biological activity and becomes a financial system with enforceable external value.

From this point forward, all economic outputs are final, auditable, and externally visible on-chain.
