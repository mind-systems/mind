HRV Computation Authority Contract (Note 27 ↔ Phase 20 Alignment)

The system defines a strict separation between transport representation of RR intervals on the mobile side and physiological computation of Heart Rate Variability metrics on the server side. This contract formalizes the relationship between Note 27 (mobile data schema) and Phase 20 (server-side signal reduction and physiological modeling), ensuring a single, unambiguous source of truth for all HRV-related computations.

The mobile layer introduces RrInterval as the canonical representation of inter-beat timing information extracted from cardiac signal sources. This representation is transmitted through the rr sample_type and conforms to the IRrIntervalSource interface defined in Note 27. The mobile system is responsible only for capturing, normalizing, and transmitting RR intervals. It does not perform any computation of derived HRV metrics that are considered authoritative for economic or physiological evaluation.

All HRV-related derived metrics, including but not limited to RMSSD, SDNN, pNN50, LF, HF, and LF/HF ratio, are computed exclusively on the server side within the HRV Stability Reducer component of Phase 20. This reducer consumes only raw rr sample_type data and performs deterministic computation over reconstructed RR interval sequences. No precomputed HRV metrics originating from the device or third-party wearable SDKs are considered authoritative inputs to the system.

Any HRV values provided by external devices or SDK-level classifiers are treated strictly as diagnostic signals with no influence on economic computation, eligibility evaluation, or hashrate aggregation. They may be stored for debugging, comparison, or calibration purposes, but they are explicitly excluded from all core physiological decision-making pipelines.

The authoritative computation flow is therefore strictly unidirectional. RR intervals originate from mobile capture systems, are transmitted as raw temporal data, are persisted in batched form without semantic modification, and are then reconstructed into continuous physiological sequences by the server-side SignalWindowAssembler. These reconstructed sequences are the sole valid input to the HRV Stability Reducer, which produces all derived HRV metrics used by downstream systems.

This design ensures that all HRV-related outputs are fully deterministic, replayable, and independent of device-specific implementations. It eliminates variability introduced by heterogeneous wearable SDKs and guarantees that physiological interpretation remains consistent across all users and devices.

It is explicitly forbidden for any downstream system, including Hashrate Aggregation, Eligibility Engine, or Anti-Fraud systems, to use device-computed HRV metrics as input. Any such values must be ignored in favor of server-derived computations based on raw RR interval data.

In summary, Note 27 defines the transport contract for RR interval acquisition, while Phase 20 defines the authoritative computation contract for HRV derivation. The server-side HRV Stability Reducer is the sole source of truth for all HRV-related physiological metrics within the system.