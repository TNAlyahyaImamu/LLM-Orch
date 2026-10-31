function [allocation, schedule] = MinMin(data, R_t, priority_weights, cfg)
%% ========================================================================
%  Min-Min Scheduling Algorithm
%  ========================================================================
%  Assigns tasks to nodes with minimum completion time (min-min heuristic)
%  ========================================================================

num_tasks = data.num_tasks;
num_nodes = cfg.num_nodes;

% Extract task durations
duration = data.duration;

% Initialize
allocation = zeros(num_tasks, 1);
schedule = zeros(num_tasks, 1);
node_available = zeros(num_nodes, 1);

% List of unassigned tasks
unassigned = 1:num_tasks;

while ~isempty(unassigned)
    % For each unassigned task, find best node
    min_completion = inf;
    best_task = [];
    best_node = [];
    
    for t = unassigned
        for n = 1:num_nodes
            completion = max(node_available(n), schedule(t)) + duration(t);
            if completion < min_completion
                min_completion = completion;
                best_task = t;
                best_node = n;
            end
        end
    end
    
    % Assign best task to best node
    if ~isempty(best_task)
        allocation(best_task) = best_node;
        schedule(best_task) = node_available(best_node);
        node_available(best_node) = schedule(best_task) + duration(best_task);
        unassigned(unassigned == best_task) = [];
    else
        break;
    end
end

end