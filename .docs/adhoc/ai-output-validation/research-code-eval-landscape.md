# Research: Evaluating AI/Agent-Generated Code Quality (2024-2026)

## The Core Problem

No existing benchmark or tool directly answers: "Given a specification (like an API spec), did an AI agent produce code that correctly and completely implements that specification?"

The closest approaches are:
- **NL2Repo-Bench** (2025) - NL requirements → complete library, evaluated against test suites. Best agents achieve <40%.
- **SWE-Bench Pro** (Scale AI, 2025) - issue descriptions as specs. Best agents score ~23%.
- **Tessl Tiles** - structured context improving API adherence by ~35%.
- **ContractSpec** (2025) - deterministic spec-to-code compilation.

## Key Findings by Category

### 1. Benchmarks Have Evolved Dramatically

| Generation | Examples | Focus | Limitation |
|---|---|---|---|
| Function-level (2021-22) | HumanEval, MBPP | Single function correctness | Too simple, frontier models >95% |
| Repository-level (2024) | SWE-bench, RepoBench, ClassEval | Real-world repos, multi-file | Solution leakage (32.67% in SWE-bench) |
| Agent-oriented (2025-26) | NL2Repo-Bench, SWE-Bench Pro, Cline-Bench | End-to-end from spec to code | Best agents still <40% on hard tasks |

**NL2Repo-Bench** is the most relevant: given only a natural-language requirements document and an empty workspace, agents must build a complete Python library. Even the strongest agents achieve below 40% test pass rates. Key failure modes: premature termination, loss of global coherence, fragile cross-file dependencies.

### 2. LLM-as-a-Judge Works But Has Rules

**CheckEval** (EMNLP 2025) - decompose evaluation into binary (yes/no) checklist items:
- Improves inter-model agreement by 0.45
- Reduces score variance vs Likert scales
- Binary decisions are more interpretable and reliable
- **This is exactly what tessl's criteria.json uses**

**CodeJudgeBench** (2025) - key findings:
- "Thinking" models (o1-class) drastically outperform standard models as code judges
- Pairwise comparison outperforms scalar pointwise judging

**CodeVisionary** (ASE 2025) - multi-agent evaluation:
- Multiple LLM agents score through negotiated consensus
- "Requirement-guided context distillation" connects evaluation directly to specifications
- Outperforms single-judge baselines

### 3. Beyond Test Passing

Research shows passing tests is necessary but insufficient:
- **Security**: >90% of outputs are either functional OR secure, but rarely both (2025)
- **Multi-turn degradation**: 20-27% drop in quality from single-turn to multi-turn (MT-Sec, NeurIPS 2025)
- **Static analysis**: Even when passing tests, GPT-4o averages 1.77 static analysis issues per task
- **Contamination**: 32.67% of SWE-bench had solution leakage; after filtering, GPT-4 dropped from 12.47% to 3.97%

### 4. Spec-Driven Development is Emerging

A clear trend toward specifications as first-class artifacts:
- **Tessl** (2025-26): Tiles as structured context, ~35% improvement in API adherence
- **AWS Kiro** (Jul 2025): agentic IDE built around spec-driven development
- **GitHub Spec Kit** (Oct 2025): spec-driven workflows for Copilot, Claude Code, etc.
- **ContractSpec** (2025): deterministic spec-first compiler for AI code
- **Academic paper** (Feb 2026): "Spec-Driven Development: From Code to Contract in the Age of AI Coding Assistants"

### 5. Industry Eval Tooling

| Tool | Approach | Code-Specific? |
|---|---|---|
| Tessl Evals | Docker container + LLM judge + weighted checklist | Yes (tiles) |
| Terminal-Bench | Docker container + verification scripts | Yes (terminal tasks) |
| Aider Benchmark | Exercism exercises across 6 languages | Yes (code editing) |
| DeepEval | pytest-style + 50 metrics + agent eval | Generic + code |
| Braintrust | Dataset + task + scorers, CI/CD integration | Generic |
| LangSmith | Human + heuristic + LLM-as-judge | Generic |
| OpenAI Evals | Dashboard + programmatic + model grading | Generic |

### 6. Statistical Treatment of Non-Determinism

Tessl's key insight: agent output is non-deterministic, so evaluation should be statistical.
- Run evaluations multiple times
- Report distributions, not single pass/fail
- Average across 3 runs per configuration
- Compare with-tile vs without-tile distributions

## Most Relevant Papers for Our Problem

1. **CheckEval** (EMNLP 2025) - binary checklist methodology (what tessl uses)
2. **NL2Repo-Bench** (2025) - spec-to-complete-library evaluation
3. **CodeVisionary** (ASE 2025) - requirement-guided multi-agent evaluation
4. **Spec-Driven Development** (Feb 2026) - theoretical framework for spec-as-source
5. **SWE-bench+** (2024) - reveals test suite weakness in evaluation
6. **MT-Sec** (NeurIPS 2025) - multi-turn quality degradation

## Implications for Tessl Tile Evaluation

The tessl eval framework is already well-aligned with the state of the art:
- **Binary checklist** (criteria.json) matches CheckEval best practice
- **Docker isolation** matches Terminal-Bench and SWE-bench patterns
- **LLM-as-judge** is the emerging standard for semantic evaluation
- **Statistical runs** (3x per config) addresses non-determinism
- **With/without comparison** measures tile effectiveness specifically

What tessl evals DON'T do (and may not need to):
- Execute the generated code (judge reads code, doesn't run it)
- Formal verification
- Security analysis (could be added to criteria)
- Multi-agent consensus judging (single judge model)
