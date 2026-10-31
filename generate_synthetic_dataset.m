function data = generate_synthetic_dataset(name)
% Generate synthetic dataset if real data not available

fprintf('  Generating synthetic %s dataset with SLA-aware durations...\n', name);

data = struct();

% Configuration
data.num_tasks = 500;    % Matches cfg.num_tasks
data.num_nodes = 50;     % Matches cfg.num_nodes

% Task IDs
data.task_id = (1:data.num_tasks)';

% ===== FIX: Generate durations that match SLA deadlines =====
% High priority (1): duration < 30ms
% Medium priority (2): duration < 150ms
% Low priority (3): duration < 400ms

% Generate priorities first (to use for duration)
data.priority = randsample([1, 2, 3], data.num_tasks, true, [0.2, 0.5, 0.3]);

% Duration based on priority (in seconds)
data.duration = zeros(data.num_tasks, 1);
for t = 1:data.num_tasks
    if data.priority(t) == 1
        % High priority: 5-30ms (0.005-0.030 seconds)
        data.duration(t) = 0.005 + 0.025 * rand();
    elseif data.priority(t) == 2
        % Medium priority: 20-150ms (0.020-0.150 seconds)
        data.duration(t) = 0.020 + 0.130 * rand();
    else
        % Low priority: 50-400ms (0.050-0.400 seconds)
        data.duration(t) = 0.050 + 0.350 * rand();
    end
end

% Resource demands (keep as before)
data.cpu_demand = 0.1 + 0.9 * rand(data.num_tasks, 1);
data.mem_demand = 0.5 + 1.5 * rand(data.num_tasks, 1);

% DAG structure (simplified)
data.dag_id = ones(data.num_tasks, 1);
data.parent_list = cell(data.num_tasks, 1);

% Node capacities
data.node_cpu = 2 + 6 * rand(data.num_nodes, 1);
data.node_mem = 4 + 12 * rand(data.num_nodes, 1);

% Policies
data.policies = struct('sla_target', 0.95, 'energy_constraint', 10000);

% Directives
data.directives = struct('text', {{'Prioritize high-priority tasks'}}, 'timestamp', {0});

fprintf('  ? Generated %d tasks with SLA-compatible durations\n', data.num_tasks);
fprintf('    High priority (%.0f%%): mean %.1f ms\n', ...
        100*sum(data.priority==1)/data.num_tasks, mean(data.duration(data.priority==1))*1000);
fprintf('    Medium priority (%.0f%%): mean %.1f ms\n', ...
        100*sum(data.priority==2)/data.num_tasks, mean(data.duration(data.priority==2))*1000);
fprintf('    Low priority (%.0f%%): mean %.1f ms\n', ...
        100*sum(data.priority==3)/data.num_tasks, mean(data.duration(data.priority==3))*1000);

end