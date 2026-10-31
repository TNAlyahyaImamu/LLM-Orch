function [allocation, schedule] = GA_SA(data, R_t, priority_weights, cfg)
%% ========================================================================
%  GA-SA: Hybrid Genetic Algorithm - Simulated Annealing
%  ========================================================================

num_tasks = data.num_tasks;
num_nodes = cfg.num_nodes;
duration = data.duration;

% Simplified GA-SA (greedy allocation with local search)
allocation = zeros(num_tasks, 1);
schedule = zeros(num_tasks, 1);
node_load = zeros(num_nodes, 1);

% Initial allocation: round-robin
for t = 1:num_tasks
    node = mod(t-1, num_nodes) + 1;
    allocation(t) = node;
end

% Local search (simulated annealing style)
temperature = 100;
for iter = 1:100
    % Random mutation
    t = randi(num_tasks);
    old_node = allocation(t);
    new_node = randi(num_nodes);
    
    % Calculate change in makespan
    old_load = node_load;
    old_load(old_node) = old_load(old_node) - duration(t);
    old_load(new_node) = old_load(new_node) + duration(t);
    
    old_makespan = max(node_load);
    new_makespan = max(old_load);
    
    % Accept if better or with probability
    if new_makespan < old_makespan || rand() < exp(-(new_makespan - old_makespan) / temperature)
        allocation(t) = new_node;
        node_load = old_load;
    end
    
    temperature = temperature * 0.95;
end

% Final schedule
schedule = zeros(num_tasks, 1);
node_load = zeros(num_nodes, 1);
for t = 1:num_tasks
    schedule(t) = node_load(allocation(t));
    node_load(allocation(t)) = node_load(allocation(t)) + duration(t);
end

end