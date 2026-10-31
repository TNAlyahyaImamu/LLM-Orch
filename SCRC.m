function [state, R_t, P_t, D_t] = SCRC(data, cfg)
%% ========================================================================
%  SCRC: Structured Contextual Resource Collector (Section 3.1)
%  ========================================================================

% ===== FIX: Use cfg.num_nodes instead of data.num_nodes =====
num_nodes = cfg.num_nodes;
num_tasks = data.num_tasks;

% R(t): Resource state vector
R_t = struct();
R_t.cpu_available = zeros(num_nodes, 1);
R_t.mem_available = zeros(num_nodes, 1);
R_t.bandwidth_available = zeros(num_nodes, 1);
R_t.energy_available = zeros(num_nodes, 1);
R_t.latency_avg = zeros(num_nodes, 1);

% ===== FIX: Ensure data.node_cpu has correct size =====
if length(data.node_cpu) ~= num_nodes
    % Regenerate node capacities if dimensions don't match
    data.node_cpu = 2 + 6 * rand(num_nodes, 1);
    data.node_mem = 4 + 12 * rand(num_nodes, 1);
end

% Assign node capacities
for n = 1:num_nodes
    R_t.cpu_available(n) = data.node_cpu(n) - 0.2 * rand() * data.node_cpu(n);
    R_t.mem_available(n) = data.node_mem(n) - 0.3 * rand() * data.node_mem(n);
    R_t.bandwidth_available(n) = 100 - 20 * rand();
    R_t.energy_available(n) = 1000 - 200 * rand();
    R_t.latency_avg(n) = 10 + 20 * rand();
end

% P(t): Policy constraints
P_t = data.policies;

% D(t): Operator directives
D_t = data.directives;

% Aggregate state
state = struct();
state.P_t = P_t;
state.D_t = D_t;
state.R_t = R_t;
state.timestamp = now;
state.iteration = 0;

end