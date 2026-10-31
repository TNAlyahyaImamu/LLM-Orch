function [workflow_schedule, W_t, prompt] = IGWA(data, allocation_plan, D_t, cfg)
%% ========================================================================
%  IGWA: Instruction-Guided Workflow Adapter (Section 3.3)
%  ========================================================================
%  This module dynamically adapts workflows in response to real-time
%  contextual changes and natural language operator directives.
%
%  Inputs:
%    data            - Dataset structure
%    allocation_plan - Resource allocation plan
%    D_t             - Operator directives
%    cfg             - Configuration parameters
%
%  Outputs:
%    workflow_schedule - Adapted workflow schedule
%    W_t               - Workflow state
%    prompt            - Generated LLM prompt
%  ========================================================================

% Generate IGWA prompt (simulated)
prompt = generate_igwa_prompt(allocation_plan, D_t, cfg);

% Simulate LLM inference latency (skip for fast testing)
if isfield(cfg.llm, 'inference_latency') && cfg.llm.inference_latency > 0
    pause(cfg.llm.inference_latency);
end

% Create task dependency graph (from data)
num_tasks = data.num_tasks;
dag_id = data.dag_id;
parent_list = data.parent_list;

% Perform topological sort
[order, levels] = dag_topological_sort(num_tasks, parent_list);

% Create workflow schedule
workflow_schedule = struct();
workflow_schedule.task_order = order;
workflow_schedule.levels = levels;
workflow_schedule.num_tasks = num_tasks;

% Apply operator directives to adapt schedule
if ~isempty(D_t) && isfield(D_t, 'text')
    % Extract directive type
    directive_text = D_t.text{1};
    
    % ===== FIX: Use strfind instead of contains =====
    if ~isempty(strfind(lower(directive_text), 'prioritize'))
        % Prioritize high-priority tasks
        high_priority = find(data.priority == 1);
        if ~isempty(high_priority)
            % ===== FIX: Ensure both are column vectors =====
            % Convert order to column vector if needed
            order_col = order(:);  % Force column vector
            high_priority_col = high_priority(:);  % Force column vector
            
            % Get remaining tasks (not high priority)
            remaining = setdiff(order_col, high_priority_col);
            
            % Combine: high priority first, then remaining
            % ===== FIX: Use vertcat or [ ; ] properly =====
            new_order = [high_priority_col; remaining];
            
            % Ensure unique and complete
            if length(new_order) == num_tasks
                workflow_schedule.task_order = new_order;
            else
                % Fallback: keep original order
                workflow_schedule.task_order = order_col;
            end
        end
    end
    
    if ~isempty(strfind(lower(directive_text), 'energy'))
        % Prefer energy-efficient nodes (simulated)
        workflow_schedule.energy_mode = true;
    end
    
    if ~isempty(strfind(lower(directive_text), 're-route')) || ...
       ~isempty(strfind(lower(directive_text), 'reroute'))
        % Handle failure response: re-route tasks
        workflow_schedule.failure_response = true;
    end
    
    if ~isempty(strfind(lower(directive_text), 'throughput'))
        % Maximize throughput
        workflow_schedule.throughput_mode = true;
    end
end

% Enforce dependency constraints (Eq. 11)
% Ensure no task is scheduled before its parents
for t = 1:num_tasks
    parents = parent_list{t};
    if ~isempty(parents)
        task_idx = find(workflow_schedule.task_order == t);
        parent_indices = zeros(length(parents), 1);
        for p = 1:length(parents)
            parent_indices(p) = find(workflow_schedule.task_order == parents(p));
        end
        max_parent_idx = max(parent_indices);
        if task_idx < max_parent_idx
            % Move task after its parents
            workflow_schedule.task_order(task_idx) = [];
            workflow_schedule.task_order = [workflow_schedule.task_order(1:max_parent_idx); ...
                                            t; ...
                                            workflow_schedule.task_order(max_parent_idx+1:end)];
        end
    end
end

% W_t: Workflow state
W_t = struct();
W_t.schedule = workflow_schedule;
W_t.status = 'adapted';
W_t.timestamp = now;

end

function prompt = generate_igwa_prompt(allocation_plan, D_t, cfg)
%% ========================================================================
%  Generate IGWA prompt (simulated) - MATLAB 2015a compatible
%  ========================================================================

% Get directive text safely
if isfield(D_t, 'text') && ~isempty(D_t.text)
    directive_text = D_t.text{1};
else
    directive_text = 'No specific directives.';
end

prompt = sprintf([
    'System: Adapt the current workflow schedule based on the following\n' ...
    'operator directive and real-time resource changes.\n\n' ...
    'Current Schedule: %d tasks in %d nodes\n' ...
    'Operator Directive: %s\n\n' ...
    'Goal: Minimize SLA violations while respecting task dependencies.'
], allocation_plan.num_tasks, allocation_plan.num_nodes, directive_text);

end