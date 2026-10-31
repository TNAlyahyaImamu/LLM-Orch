function [allocation, schedule] = HEFT(data, R_t, priority_weights, cfg)
%% ========================================================================
%  HEFT: Heterogeneous Earliest Finish Time
%  ========================================================================

num_tasks = data.num_tasks;
num_nodes = cfg.num_nodes;
duration = data.duration;
parent_list = data.parent_list;

% Compute task priorities (downward ranking)
ranks = zeros(num_tasks, 1);
for t = num_tasks:-1:1
    if isempty(parent_list{t})
        ranks(t) = mean(duration);
    else
        max_parent_rank = 0;
        for p = 1:length(parent_list{t})
            if ranks(parent_list{t}(p)) > max_parent_rank
                max_parent_rank = ranks(parent_list{t}(p));
            end
        end
        ranks(t) = mean(duration) + max_parent_rank;
    end
end

% Sort tasks by rank (descending)
[~, order] = sort(ranks, 'descend');

% Schedule tasks
allocation = zeros(num_tasks, 1);
schedule = zeros(num_tasks, 1);
node_available = zeros(num_nodes, 1);

for t = order'
    % Find node with earliest finish time
    est = zeros(num_nodes, 1);
    for n = 1:num_nodes
        est(n) = max(node_available(n), schedule(t));
    end
    [~, best_node] = min(est);
    allocation(t) = best_node;
    schedule(t) = est(best_node);
    node_available(best_node) = schedule(t) + duration(t);
end

end