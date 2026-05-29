Phase 20 — Temporal Truth Model (Data Consistency Contract)

The system defines two fundamentally different representations of time that must never be conflated: execution time and physiological time.

Execution time exists only inside the real-time computation layer. It represents the order in which signals are processed by the system and is determined by ingestion timing, streaming buffers, and internal scheduling. This timeline is strictly ephemeral, non-persistent, and cannot be reconstructed from storage. It exists solely to support low-latency computation in the live reward engine.

Physiological time is the authoritative temporal model of the system. It is defined exclusively by client timestamp embedded in each biometric sample. This timeline represents when the biological event actually occurred on the user device and is the only valid reference for all historical analysis, pattern detection, fraud evaluation, and behavioral reconstruction.

The storage format in bio_session_samples is a transport optimization and has no semantic meaning as a temporal structure. Each database row contains a batch of samples, but batch boundaries are not part of the temporal model. They exist only to reduce write amplification and network overhead.

When data is read from bio_session_samples, the system must perform a deterministic flattening step. Each batch is expanded into individual sample events, and batch identity is discarded immediately. After flattening, all samples are ordered strictly by client timestamp. No other ordering principle is valid. Server timestamps may exist in the system but are explicitly excluded from any temporal reconstruction logic.

The result of this transformation is a continuous physiological time-series stream. This stream is the only valid input for all offline systems, including SignalWindowAssembler, fraud detection engines, coaching systems, and any historical analytics.

It is explicitly forbidden for any offline or analytical system to infer behavioral conclusions from batch structure, batch order, or ingestion timing. Any such inference would constitute a violation of the temporal model and produce incorrect behavioral reconstruction artifacts.

The real-time computation layer does not consume, reconstruct, or depend on this model. It operates exclusively on in-memory streaming state and is therefore decoupled from batch storage semantics. As a result, there is no requirement for equivalence between real-time execution ordering and reconstructed physiological ordering.

In summary, the system maintains a strict dual-time architecture:

execution time is a runtime optimization artifact and is not persisted
physiological time is the canonical truth used for all historical analysis
batch structure is a storage compression layer with no semantic temporal meaning

This separation ensures that real-time performance optimization does not degrade analytical correctness, and analytical reconstruction does not impose constraints on streaming execution.