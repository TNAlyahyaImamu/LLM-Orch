function [order, levels] = dag_topological_sort(num_tasks, parent_list)
%% ========================================================================
%  DAG TOPOLOGICAL SORT: Perform topological sort on task dependency graph
%  ========================================================================

% Compute indegree
indegree = zeros(num_tasks, 1);
for t = 1:num_tasks
    parents = parent_list{t};
    if ~isempty(parents)
        for p = 1:length(parents)
            indegree(t) = indegree(t) + 1;
        end
    end
end

% Initialize queue with tasks having no dependencies
queue = find(indegree == 0);
order = [];
levels = zeros(num_tasks, 1);
current_level = 0;

while ~isempty(queue)
    % Process all tasks at current level
    current_level = current_level + 1;
    next_queue = [];
    for q = 1:length(queue)
        task = queue(q);
        order = [order; task];
        levels(task) = current_level;
        
        % Decrease indegree of dependents
        for t = 1:num_tasks
            parents = parent_list{t};
            if ~isempty(parents) && any(parents == task)
                indegree(t) = indegree(t) - 1;
                if indegree(t) == 0
                    next_queue = [next_queue; t];
                end
            end
        end
    end
    queue = next_queue;
end

% Handle any remaining tasks (shouldn't happen for valid DAG)
if length(order) < num_tasks
    remaining = setdiff(1:num_tasks, order);
    order = [order; remaining];
end

end