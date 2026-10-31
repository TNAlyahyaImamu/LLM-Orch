# LLM-Orch: Large Language Model-Driven Serverless Orchestration

<div align="center">

[![MATLAB](https://img.shields.io/badge/MATLAB-R2015a+-0076A8.svg?style=flat&logo=mathworks&logoColor=white)](https://www.mathworks.com/products/matlab.html)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Paper](https://img.shields.io/badge/Paper-Computing-blue.svg)](https://doi.org/10.1007/s00607-026-01744-8)
[![Status](https://img.shields.io/badge/Status-Published-brightgreen.svg)]()

**MATLAB Implementation of the LLM-Orch Framework**

</div>

---

📖 About

LLM-Orch is a novel **Large Language Model-driven serverless orchestration framework** for context-aware edge intelligence. It addresses the limitations of traditional heuristic and rule-based schedulers by embedding LLM reasoning at its core. The framework integrates five key innovations: Semantic Resource Prompting (SemRP), Instruction-Guided Workflow Adapter (IGWA), Explainable Orchestration Decoder (ExOD), Reinforcement-Augmented Prompt Optimizer (RAPO), and Continuous Feedback Loop (CFL).

This repository provides the MATLAB implementation associated with the paper published in *Computing* (Springer Nature).

---

## 📊 Key Results

| Metric | LLM-Orch | TFSCM | Improvement |
|--------|----------|-------|-------------|
| **Latency (ms)** | **156.8** | 187.3 | **16.3%** ↓ |
| **SLA Compliance (%)** | **94.8** | 80.2 | **15.0%** ↑ |
| **Energy (J)** | **7,050** | 8,200 | **14.1%** ↓ |
| **Inference Accuracy (%)** | **98.2** | 88.0 | **11.0%** ↑ |
| **System Utility** | **0.95** | 0.78 | **16.3%** ↑ |

### Scalability at 200 Nodes (Optimal Scale)

| Metric | Alibaba | Google Borg |
|--------|---------|-------------|
| Latency (ms) | 156.8 ± 6.1 | 208.7 ± 7.8 |
| SLA Compliance (%) | 94.8 ± 1.5 | 90.2 ± 1.9 |
| Throughput (tasks/sec) | 166.8 ± 4.9 | 145.3 ± 5.1 |
| System Utility | 0.95 ± 0.014 | 0.88 ± 0.016 |

---

## 📁 Repository Structure

```
LLM-Orch/
│
├── Main.m                               ← Main simulation script
│
├── SCRC.m                               ← Structured Contextual Resource Collector
├── SemRP.m                              ← Semantic Resource Prompting
├── IGWA.m                               ← Instruction-Guided Workflow Adapter
├── ExOD.m                               ← Explainable Orchestration Decoder
├── RAPO.m                               ← Reinforcement-Augmented Prompt Optimizer
├── CFL.m                                ← Continuous Feedback Loop
│
├── HEFT.m                               ← Heterogeneous Earliest Finish Time baseline
├── MinMin.m                             ← Min-Min scheduling baseline
├── PSO.m                                ← Particle Swarm Optimization baseline
├── GRR.m                                ← Greedy Round-Robin baseline
├── DQN_Offload.m                        ← DQN-based offloading baseline
├── GA_SA.m                              ← Hybrid GA-Simulated Annealing baseline
│
├── run_scalability_analysis.m           ← Scalability experiments
├── run_robustness_tests.m               ← Robustness experiments
├── run_statistical_analysis.m           ← Statistical analysis
├── run_ablation_study.m                 ← Ablation study
├── generate_all_figures.m               ← Generate paper figures
├── plot_results.m                       ← Plot experiment results
│
├── load_datasets.m                      ← Dataset loading utilities
├── dataset_Settings.m                   ← Dataset configuration
├── generate_synthetic_dataset.m         ← Synthetic dataset generation
├── calculate_metrics.m                  ← Performance metrics
├── dag_topological_sort.m               ← DAG topological sorting
│
├── alibaba_trace_2023_synthetic.mat     ← Alibaba-derived synthetic dataset
├── google_borg_trace_2022_synthetic.mat ← Google Borg-derived synthetic dataset
├── llm_orch_simulation_log.txt          ← Simulation log
├── llm_orch_full_simulation_log.txt     ← Full simulation log
│
├── Results/
│   ├── Figure_3_Latency.png
│   ├── Figure_4_SLA.png
│   ├── Figure_8_Throughput.png
│   ├── Figure_9_Utility.png
│   ├── Figure_10_TFSCM_Comparison.png
│   └── Figure_17_Ablation.png
│
├── README.md
└── LICENSE                              ← MIT License
```

---

## 🚀 Quick Start

### Prerequisites

- MATLAB R2015a or later
- Statistics and Machine Learning Toolbox is required for `randsample` in the synthetic-data fallback generator.
- Other toolbox dependencies have not been fully audited.

### Installation

```bash
git clone https://github.com/TNAlyahyaImamu/LLM-Orch.git
cd LLM-Orch
```

### Simulation scope

The MATLAB code provides a simulation of the proposed orchestration framework. Model identifiers such as GPT-4 and GPT-3.5-Turbo appear in the configuration, but this repository has not been verified to make live LLM API calls. The configured 1 ms inference latency is a simulation parameter, **not a measured latency for those models**. Reported results should not be treated as independently reproduced until the code and experimental settings have been validated.

### Run the Simulation

```matlab
Main
```

### Expected Output

```
=============================================================
LLM-Orch: COMPLETE SIMULATION & RESULTS GENERATOR
=============================================================

FAST MODE: Nodes=50, Tasks=500, Runs=2

✓ Alibaba: 500 tasks, 50 nodes

Running simulation...
  Run 1/2... Latency=123.4ms, SLA=97.0%
  Run 2/2... Latency=125.1ms, SLA=95.8%

✓ Simulation completed in 4.06 seconds

=============================================================
FAST TEST RESULTS
=============================================================
Average Latency: 124.2 ± 1.2 ms
Average SLA: 96.4 ± 0.8 %
=============================================================
```

---

## 📊 Running Individual Tests

| Test | Command | Output |
|------|---------|--------|
| Scalability | `run_scalability_analysis(data, cfg)` | Table VI |
| Robustness | `run_robustness_tests(data, cfg)` | Tables VII-IX |
| Statistics | `run_statistical_analysis(data, cfg)` | Tables X-XIII |
| Ablation | `run_ablation_study(data, cfg)` | Table XIII, Figure 17 |
| All Figures | `generate_all_figures(...)` | Figures 3-17 |

---

## 📄 Datasets

The repository includes synthetic datasets that mimic the structure of:

- **Alibaba Cluster Trace (2023)** - 10,000 tasks, 200 nodes
- **Google Borg Trace (2022)** - 8,000 tasks, 200 nodes

The repository includes two pre-generated synthetic `.mat` datasets in the repository root. `load_datasets.m` attempts to load these files first. If loading fails, the script generates a smaller fallback dataset (500 tasks and 50 nodes), which is **not equivalent to the full-scale experiments**. Check the MATLAB console output to confirm which dataset was used.

### Dataset Characteristics

| Feature | Alibaba | Google Borg |
|---------|---------|-------------|
| Total Tasks | 10,000 | 8,000 |
| Tasks per Job | 5-50 | 10-100 |
| CPU Demand (cores) | 0.1-8.0 | 0.05-4.0 |
| Memory Demand (GB) | 0.128-32 | 0.256-16 |
| Execution Duration | 100ms-60s | 50ms-30s |
| Priority Levels | High/Medium/Low | High/Medium/Low |

---

## 📝 Citation

```bibtex
@article{Alyahya2026LLMOrch,
  author={Alyahya, Tasniem Nasser},
  title={LLM-Orch: Large Language Model-Driven Serverless Orchestration with Reinforcement-Augmented Prompt Optimization and Continuous Feedback for Context-Aware Edge Intelligence},
  journal={Computing},
  year={2026},
  volume={108},
  number={10},
  pages={153},
  doi={10.1007/s00607-026-01744-8},
  url={https://doi.org/10.1007/s00607-026-01744-8},
  publisher={Springer Nature}
}
```

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 📧 Contact

**Tasniem Nasser Alyahya**  
Department of Computer Science, College of Computer and Information Sciences, Imam Mohammad Ibn Saud Islamic University (IMSIU), P.O. Box 5701, Riyadh 11432, Saudi Arabia.  
📧 TNAlyahya@imamu.edu.sa

---

## 🙏 Acknowledgments

- Alibaba Group for providing the Alibaba Cluster Trace
- Google for providing the Borg Trace

---

<div align="center">

**Happy Research! 🚀**

</div>
