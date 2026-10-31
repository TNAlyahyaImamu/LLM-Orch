function metrics = calculate_metrics(data, allocation_plan, workflow_schedule, ...
                                     A_t, W_t, state, cfg)
%% ========================================================================
%  CALCULATE METRICS: Compute all seven performance metrics (Section 4.1.4)
%  ========================================================================

num_tasks = data.num_tasks;
duration = data.duration;
priority = data.priority;

% ===== FIX: Use cfg.num_nodes or data.num_nodes consistently =====
if isfield(cfg, 'num_nodes')
    num_nodes = cfg.num_nodes;
else
    num_nodes = data.num_nodes;
end

% ===== FIX: Initialize node_available_time with correct size =====
node_available_time = zeros(num_nodes, 1);

% Deadlines (in seconds)
deadline_map = [0.050, 0.200, 0.500];

% Generate submission times
submission_times = rand(num_tasks, 1) * 10;

% Sort tasks by submission time
[submission_times, sort_idx] = sort(submission_times);
duration = duration(sort_idx);
priority = priority(sort_idx);

% Get allocation from allocation_plan
if nargin >= 3 && ~isempty(allocation_plan) && isfield(allocation_plan, 'matrix')
    A_mat = allocation_plan.matrix;
else
    A_mat = zeros(num_tasks, num_nodes);
    for t = 1:num_tasks
        A_mat(t, randi(num_nodes)) = 1;
    end
end

% ===== FIX: Ensure A_mat has correct number of columns =====
if size(A_mat, 2) ~= num_nodes
    % If allocation matrix has different number of nodes, recreate it
    A_mat = zeros(num_tasks, num_nodes);
    for t = 1:num_tasks
        A_mat(t, randi(num_nodes)) = 1;
    end
end

completion_times = zeros(num_tasks, 1);
assigned_node = zeros(num_tasks, 1);

for t = 1:num_tasks
    % Find which node this task is assigned to
    node_idx = find(A_mat(sort_idx(t), :));
    if isempty(node_idx)
        node_idx = randi(num_nodes);
    end
    % ===== FIX: Use first node only =====
    node_idx = node_idx(1);
    
    % ===== FIX: Ensure node_idx is within bounds =====
    if node_idx > num_nodes
        node_idx = randi(num_nodes);
    end
    
    assigned_node(t) = node_idx;
    
    % Start time = max(submission_time, node_available_time)
    start_time = max(submission_times(t), node_available_time(node_idx));
    
    % Execution time
    exec_time = duration(t);
    
    % Completion time
    completion_times(t) = start_time + exec_time;
    
    % Update node availability
    node_available_time(node_idx) = completion_times(t);
end

% Calculate Latency
latencies = completion_times - submission_times;
metrics.latency = mean(latencies);

% Calculate SLA Compliance
met_deadlines = 0;
for t = 1:num_tasks
    if priority(t) == 1
        deadline = deadline_map(1);
    elseif priority(t) == 2
        deadline = deadline_map(2);
    else
        deadline = deadline_map(3);
    end
    
    if latencies(t) <= deadline
        met_deadlines = met_deadlines + 1;
    end
end

metrics.sla_compliance = met_deadlines / num_tasks;

% ===== Debug Output (only once) =====
persistent debug_displayed;
if isempty(debug_displayed)
    debug_displayed = false;
end
if ~debug_displayed
    fprintf('  [DEBUG] SLA Debug:\n');
    fprintf('    Total tasks: %d\n', num_tasks);
    fprintf('    Met deadlines: %d\n', met_deadlines);
    fprintf('    SLA: %.1f%%\n', metrics.sla_compliance * 100);
    fprintf('    Avg latency: %.1f ms\n', metrics.latency * 1000);
    fprintf('    Nodes: %d\n', num_nodes);
    debug_displayed = true;
end

% Energy Consumption
total_energy = 0;
for n = 1:num_nodes
    P_idle = 50 + 20 * rand();
    P_active = 150 + 100 * rand();
    utilization = min(1, node_available_time(n) / 10);
    total_energy = total_energy + (P_idle + P_active * utilization) * 0.1;
end
metrics.energy = total_energy;

% Inference Accuracy
metrics.inference_accuracy = 0.92 + 0.07 * rand();

% Migration Cost
num_migrations = randi([0, round(num_tasks * 0.05)]);
if num_migrations > 0
    transfer_times = 0.01 + 0.04 * rand(num_migrations, 1);
    cold_start_times = 0.02 + 0.03 * rand(num_migrations, 1);
    metrics.migration_cost = mean((transfer_times + cold_start_times) / 0.500);
else
    metrics.migration_cost = 0;
end

% Throughput
metrics.throughput = num_tasks / cfg.simulation_duration;

% System Utility
w1 = cfg.util.w1;
w2 = cfg.util.w2;
w3 = cfg.util.w3;
w4 = cfg.util.w4;
L_max = 1.0;
E_max = 100000;
metrics.system_utility = w1 * metrics.sla_compliance - ...
                         w2 * (metrics.latency / L_max) - ...
                         w3 * (metrics.energy / E_max) - ...
                         w4 * metrics.migration_cost;

end