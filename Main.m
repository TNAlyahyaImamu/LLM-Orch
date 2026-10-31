%% ========================================================================
%  LLM-Orch: COMPLETE SIMULATION & RESULTS GENERATOR
%  MATLAB 2015a Compatible
clear; clc; close all;
diary('llm_orch_full_simulation_log.txt');

fprintf('=============================================================\n');
fprintf('LLM-Orch: COMPLETE SIMULATION & RESULTS GENERATOR\n');
fprintf('=============================================================\n\n');

%% ========================================================================
%  PART 1: CONFIGURATION PARAMETERS
%  ========================================================================

cfg = struct();

% ===== Infrastructure =====
cfg.cpu_cores_per_node = 8;
cfg.mem_gb_per_node = 32;
cfg.bandwidth_per_node = 1000;
cfg.energy_budget_per_node = 1000;
cfg.simulation_duration = 3600;
cfg.cold_start_overhead = 0.050;
cfg.max_concurrent_functions = 100;

% ===== LLM Parameters (Table III) =====
cfg.llm.temperature = 0.2;
cfg.llm.max_tokens_semrp = 1024;
cfg.llm.max_tokens_igwa = 1024;
cfg.llm.max_tokens_exod = 256;
cfg.llm.inference_latency = 0.001;  % 1ms for fast testing
cfg.llm.model_gpt4 = 'GPT-4';
cfg.llm.model_gpt35 = 'GPT-3.5-Turbo';

% ===== Hyperparameters (Table V) =====
cfg.hp.omega1 = 0.5;
cfg.hp.omega2 = 0.3;
cfg.hp.omega3 = 0.2;
cfg.hp.eta = 0.001;
cfg.hp.gamma = 0.95;
cfg.hp.lambda = 0.3;
cfg.hp.alpha = 0.4;
cfg.hp.beta = 0.35;
cfg.hp.gamma_exod = 0.25;

% ===== System Utility Weights (Eq. 34) =====
cfg.util.w1 = 0.4;
cfg.util.w2 = 0.3;
cfg.util.w3 = 0.2;
cfg.util.w4 = 0.1;

% ===== Simulation Parameters =====
cfg.num_runs = 10;          % As per paper
cfg.num_tasks = 1000;      % As per Table IV
cfg.node_counts = [10, 50, 100, 150, 200];
cfg.random_seed = 42;

fprintf('Configuration loaded:\n');
fprintf('  - Node counts: %s\n', mat2str(cfg.node_counts));
fprintf('  - Tasks: %d\n', cfg.num_tasks);
fprintf('  - Runs per configuration: %d\n\n', cfg.num_runs);

%% ========================================================================
%  PART 2: LOAD DATASETS
%  ========================================================================

addpath('./Utils/');
addpath('./Modules/');
addpath('./Baselines/');

[alibaba, google_borg] = load_datasets();
data = alibaba;  % Primary dataset

fprintf('? Loaded Alibaba dataset: %d tasks, %d nodes\n\n', data.num_tasks, data.num_nodes);

%% ========================================================================
%  PART 3: RUN SCALABILITY ANALYSIS (Table VI)
%  ========================================================================

fprintf('=============================================================\n');
fprintf('PART 3: Scalability Analysis (Table VI)\n');
fprintf('=============================================================\n');

scalability_results = run_scalability_analysis(data, cfg);

%% ========================================================================
%  PART 4: ROBUSTNESS TESTS (Tables VII-IX)
%  ========================================================================

fprintf('\n=============================================================\n');
fprintf('PART 4: Robustness Tests (Tables VII-IX)\n');
fprintf('=============================================================\n');

robustness_results = run_robustness_tests(data, cfg);

%% ========================================================================
%  PART 5: STATISTICAL ANALYSIS (Tables X-XII)
%  ========================================================================

fprintf('\n=============================================================\n');
fprintf('PART 5: Statistical Analysis (Tables X-XII)\n');
fprintf('=============================================================\n');

stat_results = run_statistical_analysis(data, cfg);

%% ========================================================================
%  PART 6: ABLATION STUDY (Table XIII, Figure 17)
%  ========================================================================

fprintf('\n=============================================================\n');
fprintf('PART 6: Ablation Study (Table XIII, Figure 17)\n');
fprintf('=============================================================\n');

ablation_results = run_ablation_study(data, cfg);

%% ========================================================================
%  PART 7: GENERATE ALL FIGURES
%  ========================================================================

fprintf('\n=============================================================\n');
fprintf('PART 7: Generating All Figures\n');
fprintf('=============================================================\n');

% ===== FIX: Add the function to path =====
addpath('./');

% Generate figures
 generate_all_figures(scalability_results, robustness_results, ablation_results, cfg);


diary off;
