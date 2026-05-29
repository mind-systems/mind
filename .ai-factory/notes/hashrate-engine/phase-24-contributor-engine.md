# Phase 24 — Contributor Engine

The Contributor Engine is the first layer in the Bio-Proof-of-Brain architecture where physiological state is transformed into economic mining influence.

All previous systems exist to answer foundational questions:

* what biological state occurred,
* how reliable the telemetry was,
* whether the behavior appears authentic,
* what the user’s adaptive baseline is.

The Contributor Engine is the system that finally answers:

* how much meaningful biological work was performed during this epoch.

This distinction is critical.

The Contributor Engine does not process raw telemetry, does not perform signal reduction, does not estimate trustworthiness, and does not analyze fraud behavior. Those responsibilities already belong to earlier layers.

The Contributor Engine exists solely to interpret normalized biological state economically.

Architecturally, the engine sits after all trust and personalization systems.

```text id="bnn6mg"
Signal Reduction Pipeline
    ↓
Quality Engine
    ↓
Anti-Fraud Engine
    ↓
User BioProfile Engine
    ↓
Contributor Engine
    ↓
Contributor Results
    ↓
Hashrate Aggregation Engine
```

The engine consumes:

* reduced physiological state,
* quality reports,
* fraud-risk reports,
* user biological profile,
* contributor configuration.

It produces:

* contributor-level mining influence signals.

The architecture intentionally decomposes scoring into isolated contributors instead of using one monolithic “brain score.”

This is one of the most important structural decisions in the entire mining system.

Human biological regulation is multidimensional.

Different physiological qualities represent fundamentally different forms of biological work.

For example:

* maintaining calm under stress,
* sustaining focused attention,
* recovering efficiently,
* improving regulation consistency,
* stabilizing alpha activity,
* preserving emotional coherence

are all distinct phenomena.

Collapsing them into one opaque score would make the protocol:

* impossible to tune,
* impossible to audit,
* impossible to personalize,
* impossible to evolve scientifically.

The Contributor Engine therefore models mining influence as a weighted composition of independent physiological contributors.

Each contributor represents one interpretable dimension of biological performance.

The engine introduces the concept of contributor isolation.

A contributor must be:

* independently configurable,
* independently replayable,
* independently removable,
* independently tunable,
* independently versioned.

This is essential because the scientific understanding of physiological regulation will evolve continuously over time.

The architecture must allow:

* adding new contributors,
* retiring broken contributors,
* adjusting contributor influence,
* experimenting with mining models

without destabilizing the rest of the system.

Each contributor implements a shared interface.

```ts id="f7o0nl"
interface HashRateContributor<
  TState = ReducedBioState
> {
  id: string;

  version: number;

  weight: number;

  compute(
    state: TState,
    profile: UserBioProfile,
    quality: SignalQualityReport,
    fraud: FraudRiskReport,
  ): Promise<ContributorResult>;
}
```

The interface is intentionally narrow.

A contributor receives:

* the current reduced physiological epoch,
* the user’s adaptive baseline profile,
* signal confidence context,
* fraud-risk context.

It returns only its own isolated contribution.

Contributors must never:

* read databases directly,
* modify rewards,
* inspect wallets,
* query historical telemetry,
* communicate with other contributors.

This isolation guarantees determinism and replayability.

The Contributor Engine introduces the concept of biological effort interpretation.

The protocol is not attempting to reward raw physiology.

It is attempting to reward meaningful self-regulation activity relative to the user’s own evolving capability.

This distinction is extremely important.

For example:

* naturally high alpha should not automatically produce dominant mining power,
* genetically favorable HRV should not guarantee superior rewards,
* elite meditators should not permanently monopolize emission.

Instead, contributors evaluate:

* regulation quality,
* sustainability,
* consistency,
* adaptive improvement,
* intentional control,
* resilience.

The BioProfile Engine makes this possible by providing individualized baselines.

A contributor therefore evaluates physiological state relative to personalized context rather than fixed universal thresholds.

For example, a focus contributor may evaluate:

* sustained attention relative to personal baseline,
* fatigue resistance relative to historical capacity,
* stability relative to expected variance.

Likewise, a recovery contributor may evaluate:

* HRV restoration quality relative to user recovery norms,
* stress reduction efficiency relative to historical recovery speed.

This architecture transforms the protocol from:

* absolute biometric competition

into:

* adaptive self-regulation mining.

The engine intentionally separates contributor scoring from trust scoring.

A user may produce:

* extremely strong physiological performance,
* but low signal quality,
* or elevated fraud risk.

Contributors therefore never assume telemetry is trustworthy.

Instead:

* Quality Engine influences confidence,
* Anti-Fraud Engine influences trust weighting,
* contributors interpret only biological meaning.

This separation is critical because fraud and biology evolve independently.

The Contributor Engine also introduces contributor confidence scaling.

A contributor’s output is never treated as absolute.

Its influence depends on:

* signal quality,
* profile certainty,
* fraud-risk conditions,
* physiological coherence.

This allows mining influence to degrade gracefully rather than through binary rejection.

For example:

* noisy EEG may reduce alpha contributor confidence,
* unstable HRV windows may suppress recovery contributors,
* suspicious repeated patterns may reduce contributor influence,
* weak profile history may lower personalization certainty.

The architecture therefore supports uncertainty-aware scoring.

The Contributor Engine intentionally avoids direct psychological interpretation.

The protocol cannot reliably infer:

* happiness,
* enlightenment,
* emotional worth,
* mental health state,
* subjective well-being.

Contributors evaluate only measurable regulation dynamics.

This boundary is ethically important.

The system must never position itself as a psychological authority.

The initial contributor families are expected to include:

* relaxation regulation,
* sustained focus,
* recovery efficiency,
* emotional stability,
* alpha control,
* consistency discipline,
* fatigue resilience,
* session completion quality.

However, contributors remain fully modular.

Future mining modes may introduce:

* respiratory regulation,
* posture coherence,
* sleep recovery,
* neurofeedback mastery,
* physical recovery,
* adaptive meditation training.

The architecture must support these additions without changing the engine itself.

The Contributor Engine produces structured contributor outputs.

```ts id="nl5lxy"
interface ContributorResult {
  contributorId: string;

  version: number;

  score: number;

  confidence: number;

  weightedScore: number;

  metadata?: Record<string, unknown>;
}
```

The `score` represents the contributor’s raw physiological interpretation.

The `confidence` represents how trustworthy and stable the evaluation is under current conditions.

The `weightedScore` represents the contributor’s effective influence after weighting and trust adjustments.

The Contributor Engine itself does not aggregate contributors into final hashrate.

That responsibility belongs to the Hashrate Aggregation Engine introduced later.

This separation is extremely important.

Contributors evaluate biological meaning.

Aggregation evaluates economic policy.

Keeping those systems separate allows:

* changing mining economics,
* changing weighting policy,
* introducing temporary events,
* adjusting protocol incentives,
* creating specialized mining modes

without rewriting contributor logic.

The engine must remain deterministic and replayable.

Given:

* identical reduced epochs,
* identical profiles,
* identical quality reports,
* identical fraud reports,
* identical contributor versions,
* identical contributor configuration,

the contributor outputs must always be identical.

Replayability is mandatory because contributor behavior directly influences future reward allocation.

The engine must also remain explainable.

Opaque scoring systems are unacceptable in a protocol intended to allocate economic value.

Every contributor output must remain attributable to:

* specific physiological conditions,
* specific profile comparisons,
* specific confidence modifiers.

This is essential for:

* auditing,
* debugging,
* protocol governance,
* scientific iteration,
* future user-facing coaching.

The Contributor Engine is one of the architectural centers of the entire Bio-Proof-of-Brain system because it defines how authentic biological self-regulation is translated into mining influence.

All later economics operate on top of the contributor outputs generated here.
