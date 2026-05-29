Phase 20 — Signal Reduction Pipeline

The Signal Reduction Pipeline is the first computational layer above raw biometric ingestion. Its purpose is to transform heterogeneous realtime telemetry streams into stable, normalized, time-aligned physiological state representations suitable for downstream systems such as Quality Engine, Anti-Fraud, BioProfile adaptation, Contributor scoring, and reward emission.

This phase introduces the boundary between transport-level telemetry and domain-level signal intelligence.

The system currently stores biometric samples as opaque JSON payloads grouped into session batches (bio_session_samples). Those samples originate from multiple realtime producers with different frequencies, timing characteristics, noise profiles, and reliability guarantees. Raw samples are intentionally preserved unchanged because they represent the canonical historical telemetry source. However, downstream scoring systems must never operate directly on raw telemetry.

The Signal Reduction Pipeline solves this by introducing deterministic epoch-based signal reduction.

The pipeline is responsible for:

assembling aligned signal windows from raw telemetry,
normalizing timestamps and sampling density,
reducing noisy realtime streams into stable physiological metrics,
isolating artifact handling from scoring logic,
producing deterministic reduced state snapshots for later engines.

The pipeline must not perform reward scoring, anti-fraud actions, blockchain operations, coaching decisions, or economic calculations. Its only responsibility is physiological signal reduction.

The pipeline operates entirely server-side.

Architectural Position

The pipeline sits between telemetry persistence and all higher-order intelligence systems.

mobile realtime streams
    ↓
ModuleBiometricStreamService
    ↓
bio_session_samples
    ↓
Signal Reduction Pipeline
    ↓
ReducedBioStateEpoch
    ↓
Quality Engine
    ↓
AntiFraud Engine
    ↓
Contributor Engine

The Signal Reduction Pipeline is therefore the canonical transformation boundary between:

raw telemetry,
normalized physiological state.

All later engines consume reduced epochs, never raw samples.

Design Principles

The pipeline must follow several strict architectural principles.

Raw telemetry is immutable. Reduction never modifies historical source samples.

Reduction is deterministic. Given the same telemetry history and the same reducer version, the output must always be identical.

Reducers are isolated. A reducer must never know about rewards, contributors, economics, wallets, or emission schedules.

Reduction is epoch-based rather than continuous. All downstream systems operate on discrete epochs with explicit time boundaries.

Signal reduction is modular. Adding a new physiological metric must require adding a new reducer only, without modifying the rest of the pipeline.

The pipeline must tolerate:

irregular packet timing,
dropped samples,
temporary stream interruptions,
mixed sampling frequencies,
partially missing signals,
future sensor types.

The system must preserve replayability. Reduced epochs must be reproducible from raw telemetry at any future point.

Epoch Model

The pipeline introduces a fixed processing unit called a Reduction Epoch.

A Reduction Epoch is a deterministic time window over which signal reduction occurs.

Initial implementation uses:

epoch duration: 15 seconds,
epoch alignment: absolute UTC boundaries.

Example:

12:00:00.000 → 12:00:15.000
12:00:15.000 → 12:00:30.000
12:00:30.000 → 12:00:45.000

Epoch alignment must not depend on:

session start,
client timing,
device timing.

This guarantees deterministic replay and cross-user comparability.

The epoch duration must be configurable later, but all reducers within one environment must use the same duration.

Signal Window Assembly

Raw telemetry arrives asynchronously from multiple sample producers.

Examples:

EEG bands at 4 Hz,
HRV metrics at 1 Hz,
emotional classifiers at irregular intervals,
future respiratory sensors at custom frequencies.

The first responsibility of the pipeline is assembling coherent signal windows.

This is implemented by the SignalWindowAssembler.

The assembler reads raw telemetry from bio_session_samples and reconstructs all samples belonging to a target epoch.

The assembler is responsible for:

timestamp ordering,
deduplication,
late packet handling,
sample grouping,
cross-stream alignment,
interpolation preparation.

The assembler must never compute physiological metrics itself.

Signal Window Rules

Each signal type receives an independent signal window.

Example:

epoch: 12:00:00 → 12:00:15

cardio window:
  15 samples @ 1Hz

eeg window:
  60 samples @ 4Hz

emotions window:
  5 irregular samples

Reducers receive fully materialized windows.

Reducers must not query the database themselves.

Reducers must not depend on realtime stream timing.

Timestamp Handling

All timestamps are canonicalized server-side.

The server timestamp becomes authoritative at ingestion time.

Client timestamps are preserved for diagnostics but are not authoritative for reduction ordering.

The reduction pipeline uses:

ingestion timestamp,
normalized epoch assignment.

Future support for clock skew correction may be added later, but Phase 20 assumes server-time authority.

Late Samples

Realtime mobile networks may deliver delayed packets.

The pipeline therefore introduces a reduction finalization delay.

Example:

epoch duration: 15s,
reduction delay: 5s.

An epoch ending at:

12:00:15

is finalized at:

12:00:20

Any samples arriving after finalization are ignored for that epoch and flagged for diagnostics.

This guarantees deterministic outputs.

Signal Reducers

Reducers are isolated computational units responsible for transforming raw signal windows into stable physiological metrics.

Reducers are pure computational modules.

Reducers:

must not access external services,
must not write to databases,
must not know about users,
must not know about rewards.

Reducers operate only on:

signal windows,
reducer configuration.
Reducer Interface

All reducers implement a shared interface.

interface SignalReducer<
  TInput,
  TOutput
> {
  id: string;

  version: number;

  supportedSampleType: string;

  reduce(
    window: SignalWindow<TInput>,
  ): Promise<TOutput>;
}

The version field is critical for replayability.

Changing reduction math must increment reducer versions.

Historical epochs preserve the reducer version used to generate them.

Initial Reducer Set

Phase 20 introduces only foundational reducers required for future scoring systems.

No reward scoring occurs yet.

The initial reducer set includes:

EEG Reducers
Alpha Stability Reducer

Produces:

alpha mean,
alpha variance,
alpha trend slope,
alpha persistence.

The reducer smooths short spikes and suppresses transient artifacts.

Band Entropy Reducer

Measures:

band unpredictability,
repetition signatures,
temporal uniformity.

This reducer becomes foundational for future repeated-pattern fraud analysis.

EEG Artifact Ratio Reducer

Detects:

flatline periods,
clipping,
impossible transitions,
extreme spikes.

Produces a normalized artifact ratio for the epoch.

Cardio Reducers
HRV Stability Reducer

Produces:

rolling RMSSD,
SDNN trend,
HRV variance,
HRV confidence.

The reducer must tolerate sparse HRV availability.

Heart Rate Stability Reducer

Produces:

average heart rate,
variability slope,
freeze detection,
rhythm continuity.
Emotional State Reducers
Focus Stability Reducer

Produces:

sustained attention score,
attention volatility,
fatigue drift.
Cognitive Load Reducer

Produces:

rolling cognitive load,
overload persistence,
recovery speed.
Reduced State Model

Reducers emit domain-level physiological state objects.

All reducer outputs are merged into a single epoch state snapshot.

interface ReducedBioState {
  epochStartedAt: Date;

  epochEndedAt: Date;

  eeg?: ReducedEegState;

  cardio?: ReducedCardioState;

  emotions?: ReducedEmotionState;

  metadata: {
    reducerVersions: Record<string, number>;
  };
}

The reduced state becomes the canonical input for all future engines.

Persistence

Reduced epochs must be persisted separately from raw telemetry.

A new table will eventually store reduced epochs.

Raw telemetry is append-only historical evidence.

Reduced epochs are derived computational products.

The reduced epoch store enables:

replay,
rescoring,
fraud audits,
contributor recalculation,
future ML training.

Phase 20 does not yet define the final database schema, but the architecture must assume persistence exists.

Replayability

Replayability is a core requirement of the entire mining architecture.

The system must support:

reducer upgrades,
scoring algorithm upgrades,
fraud model improvements,
economic recalculations.

Therefore:

raw telemetry remains immutable,
reducers are versioned,
reduced epochs are reproducible.

A future replay engine will be able to:

read historical raw telemetry,
rerun reducers,
regenerate reduced epochs,
recompute hashrate,
recompute rewards.

Nothing in Phase 20 may prevent future replay execution.

Failure Handling

Reducer failures must never terminate ingestion pipelines.

If a reducer fails:

the failure is logged,
the epoch remains partially reduced,
failed reducer output is omitted,
downstream systems receive incomplete state with diagnostics.

One failing reducer must never block:

other reducers,
epoch persistence,
realtime processing.
Performance Requirements

The pipeline must support:

thousands of concurrent active sessions,
low-frequency realtime processing,
replay jobs,
historical rescoring.

Reducers therefore must remain computationally lightweight.

Heavy DSP and ML workloads are explicitly out of scope for Phase 20.

All reducers should operate in:

linear time,
bounded memory,
per-epoch isolation.
Out of Scope

Phase 20 explicitly does not include:

hashrate computation,
reward distribution,
blockchain integration,
fraud penalties,
user baselines,
contributor weighting,
coaching logic,
ML classification,
economic balancing.

Those systems consume reduced epochs later.

Phase 20 only establishes the physiological signal reduction substrate required for the rest of the architecture.