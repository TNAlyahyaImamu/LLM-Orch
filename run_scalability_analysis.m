function results = run_scalability_analysis(data, cfg)
%% ========================================================================
%  run_scalability_analysis: Generate Table VI
%  ========================================================================

node_counts = cfg.node_counts;
num_runs = cfg.num_runs;

results = struct();
results.node_counts = node_counts;
results.num_runs = num_runs;

% Initialize result arrays
latency_mean = zeros(length(node_counts), 1);
latency_std = zeros(length(node_counts), 1);
sla_mean = zeros(length(node_counts), 1);
sla_std = zeros(length(node_counts), 1);
tp_mean = zeros(length(node_counts), 1);
tp_std = zeros(length(node_counts), 1);
utility_mean = zeros(length(node_counts), 1);  % ===== NEW =====
utility_std = zeros(length(node_counts), 1);   % ===== NEW =====

for n_idx = 1:length(node_counts)
    cfg.num_nodes = node_counts(n_idx);
    fprintf('\n--- Nodes: %d ---\n', cfg.num_nodes);
    
    % Ensure data.num_nodes matches cfg.num_nodes
    data.num_nodes = cfg.num_nodes;
    data.node_cpu = 2 + 6 * rand(cfg.num_nodes, 1);
    data.node_mem = 4 + 12 * rand(cfg.num_nodes, 1);
    
    all_latency = zeros(num_runs, 1);
    all_sla = zeros(num_runs, 1);
    all_tp = zeros(num_runs, 1);
    all_utility = zeros(num_runs, 1);  % ===== NEW =====
    
    for run = 1:num_runs
        rng(cfg.random_seed + run + n_idx * 1000);
        
        % Run full pipeline
        [state, R_t, P_t, D_t] = SCRC(data, cfg);
        [allocation_plan, A_t, ~] = SemRP(state, P_t, D_t, cfg);
        [workflow_schedule, W_t, ~] = IGWA(data, allocation_plan, D_t, cfg);
        [~, ~, ~] = ExOD(allocation_plan, workflow_schedule, P_t, D_t, cfg);
        [~, ~, ~] = RAPO(A_t, W_t, state, cfg);
        [~, ~] = CFL(state, R_t, W_t, D_t, cfg);
        metrics = calculate_metrics(data, allocation_plan, workflow_schedule, ...
                                    A_t, W_t, state, cfg);
        
        all_latency(run) = metrics.latency * 1000;
        all_sla(run) = metrics.sla_compliance * 100;
        all_tp(run) = metrics.throughput;
        all_utility(run) = metrics.system_utility;  % ===== NEW =====
    end
    
    latency_mean(n_idx) = mean(all_latency);
    latency_std(n_idx) = std(all_latency);
    sla_mean(n_idx) = mean(all_sla);
    sla_std(n_idx) = std(all_sla);
    tp_mean(n_idx) = mean(all_tp);
    tp_std(n_idx) = std(all_tp);
    utility_mean(n_idx) = mean(all_utility);  % ===== NEW =====
    utility_std(n_idx) = std(all_utility);   % ===== NEW =====
    
    fprintf('  ? Latency=%.1f±%.1f ms, SLA=%.1f±%.1f%%, TP=%.1f±%.1f, Util=%.3f±%.3f\n', ...
            latency_mean(n_idx), latency_std(n_idx), ...
            sla_mean(n_idx), sla_std(n_idx), ...
            tp_mean(n_idx), tp_std(n_idx), ...
            utility_mean(n_idx), utility_std(n_idx));
end

% Store results
results.latency = struct('mean', latency_mean, 'std', latency_std);
results.sla = struct('mean', sla_mean, 'std', sla_std);
results.throughput = struct('mean', tp_mean, 'std', tp_std);
results.utility = struct('mean', utility_mean, 'std', utility_std);  % ===== NEW =====

% Display Table VI
fprintf('\n=============================================================\n');
fprintf('Table VI: Scalability Performance\n');
fprintf('=============================================================\n');
fprintf(' Nodes | Latency (ms) | SLA (%) | Throughput (tasks/sec) | Utility\n');
fprintf('-------|--------------|---------|------------------------|--------\n');
for n = 1:length(node_counts)
    fprintf(' %4d  | %8.1f ± %-5.1f | %6.1f ± %-5.1f | %8.1f ± %-5.1f | %6.3f ± %-5.3f\n', ...
            node_counts(n), latency_mean(n), latency_std(n), ...
            sla_mean(n), sla_std(n), tp_mean(n), tp_std(n), ...
            utility_mean(n), utility_std(n));
end

end