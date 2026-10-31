function [allocation, schedule] = GRR(data, R_t, priority_weights, cfg)
%% ========================================================================
%  GRR: Greedy Round-Robin
%  ========================================================================

num_tasks = data.num_tasks;
num_nodes = cfg.num_nodes;

allocation = zeros(num_tasks, 1);
schedule = zeros(num_tasks, 1);
node_idx = 0;

for t = 1:num_tasks
    node_idx = mod(node_idx, num_nodes) + 1;
    allocation(t) = node_idx;
    schedule(t) = t * 0.01;  % Simple schedule
end

end