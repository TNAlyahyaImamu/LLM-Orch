function [allocation, schedule] = DQN_Offload(data, R_t, priority_weights, cfg)
%% ========================================================================
%  DQN-Offload: Deep Q-Network Based Offloading
%  ========================================================================

num_tasks = data.num_tasks;
num_nodes = cfg.num_nodes;
duration = data.duration;

% Simplified DQN (greedy allocation with exploration)
allocation = zeros(num_tasks, 1);
schedule = zeros(num_tasks, 1);
node_load = zeros(num_nodes, 1);

epsilon = 0.1;  % Exploration rate

for t = 1:num_tasks
    if rand() < epsilon
        % Explore: random allocation
        node = randi(num_nodes);
    else
        % Exploit: choose node with minimum load
        [~, node] = min(node_load);
    end
    allocation(t) = node;
    schedule(t) = node_load(node);
    node_load(node) = node_load(node) + duration(t);
end

end