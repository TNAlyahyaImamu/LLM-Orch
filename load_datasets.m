function [alibaba, google_borg] = load_datasets()
%% ========================================================================
%  LOAD DATASETS: Load Alibaba and Google Borg trace data
%  ========================================================================

% Try to load existing datasets
try
    load('./Datasets/alibaba_trace_2023_synthetic.mat', 'alibaba_dataset');
    alibaba = alibaba_dataset;
    alibaba.num_tasks = length(alibaba.tasks.task_id);
    alibaba.num_nodes = length(alibaba.nodes.machine_id);
    alibaba.task_id = alibaba.tasks.task_id;
    alibaba.cpu_demand = alibaba.tasks.cpu_demand;
    alibaba.mem_demand = alibaba.tasks.mem_demand;
    alibaba.priority = alibaba.tasks.priority;
    alibaba.duration = alibaba.tasks.duration;
    alibaba.dag_id = alibaba.tasks.dag_id;
    alibaba.parent_list = alibaba.tasks.parent_list;
    alibaba.node_cpu = alibaba.nodes.cpu_num;
    alibaba.node_mem = alibaba.nodes.mem_size;
    alibaba.policies = alibaba.policies;
    alibaba.directives = alibaba.directives;
    fprintf('  ? Loaded existing Alibaba dataset.\n');
catch
    fprintf('  ? Alibaba dataset not found. Generating new synthetic data...\n');
    alibaba = generate_synthetic_dataset('alibaba');
end

% Try to load existing datasets
try
    load('./Datasets/google_borg_trace_2022_synthetic.mat', 'borg_dataset');
    google_borg = borg_dataset;
    google_borg.num_tasks = length(google_borg.tasks.task_id);
    google_borg.num_nodes = length(google_borg.nodes.machine_id);
    google_borg.task_id = google_borg.tasks.task_id;
    google_borg.cpu_demand = google_borg.tasks.cpu_request;
    google_borg.mem_demand = google_borg.tasks.memory_request;
    google_borg.priority = google_borg.tasks.priority;
    google_borg.duration = google_borg.tasks.duration;
    google_borg.dag_id = google_borg.tasks.dag_id;
    google_borg.parent_list = google_borg.tasks.parent_list;
    google_borg.node_cpu = google_borg.nodes.cpu_capacity;
    google_borg.node_mem = google_borg.nodes.memory_capacity;
    google_borg.policies = google_borg.policies;
    google_borg.directives = google_borg.directives;
    fprintf('  ? Loaded existing Google Borg dataset.\n');
catch
    fprintf('  ? Google Borg dataset not found. Generating new synthetic data...\n');
    google_borg = generate_synthetic_dataset('google_borg');
end

end

%% ========================================================================
%  GENERATE SYNTHETIC DATASET (SLA-Aware)
%  ========================================================================

function data = generate_synthetic_dataset(name)
% Generate synthetic dataset with SLA-aware durations

fprintf('  Generating synthetic %s dataset with SLA-aware durations...\n', name);

data = struct();

% Configuration
data.num_tasks = 500;
data.num_nodes = 50;

% Task IDs
data.task_id = (1:data.num_tasks)';

% ===== IMPORTANT: Generate durations that match SLA deadlines =====
% High priority (1): duration < 30ms (to meet 50ms deadline)
% Medium priority (2): duration < 150ms (to meet 200ms deadline)
% Low priority (3): duration < 400ms (to meet 500ms deadline)

% Generate priorities first (20% high, 50% medium, 30% low)
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

% Resource demands
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

% Stats
fprintf('  ? Generated %d tasks with SLA-compatible durations\n', data.num_tasks);
fprintf('    High priority (%.0f%%): mean %.1f ms\n', ...
        100*sum(data.priority==1)/data.num_tasks, mean(data.duration(data.priority==1))*1000);
fprintf('    Medium priority (%.0f%%): mean %.1f ms\n', ...
        100*sum(data.priority==2)/data.num_tasks, mean(data.duration(data.priority==2))*1000);
fprintf('    Low priority (%.0f%%): mean %.1f ms\n', ...
        100*sum(data.priority==3)/data.num_tasks, mean(data.duration(data.priority==3))*1000);

end