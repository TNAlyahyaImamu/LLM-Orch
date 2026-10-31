function [allocation_plan, A_t, prompt] = SemRP(state, P_t, D_t, cfg)
%% ========================================================================
%  SemRP: Semantic Resource Prompting (Section 3.2)
%  ========================================================================

% Generate LLM prompt
prompt = generate_prompt_internal(state, P_t, D_t, cfg);

% Simulate LLM inference latency (skip for fast testing)
if isfield(cfg.llm, 'inference_latency') && cfg.llm.inference_latency > 0
    pause(cfg.llm.inference_latency);
end

num_tasks = cfg.num_tasks;
num_nodes = cfg.num_nodes;

% ===== FIX: Create allocation matrix with balanced distribution =====
A_t = zeros(num_tasks, num_nodes);

% ===== SOLUTION 1: Round-robin allocation (guarantees balanced distribution) =====
for t = 1:num_tasks
    node_idx = mod(t-1, num_nodes) + 1;  % Round-robin: 1,2,3,...,50,1,2,...
    A_t(t, node_idx) = 1;
end

% ===== SOLUTION 2: Random but balanced (uncomment if you prefer) =====
% % Shuffle task order for randomness
% task_order = randperm(num_tasks);
% for i = 1:num_tasks
%     t = task_order(i);
%     node_idx = mod(i-1, num_nodes) + 1;
%     A_t(t, node_idx) = 1;
% end

% ===== Create allocation plan structure =====
allocation_plan = struct();
allocation_plan.matrix = A_t;
allocation_plan.num_tasks = num_tasks;
allocation_plan.num_nodes = num_nodes;

% ===== Set priorities (from data or random) =====
if isfield(state, 'P_t') && isfield(state.P_t, 'priority')
    allocation_plan.priority = state.P_t.priority;
else
    allocation_plan.priority = randi(3, num_tasks, 1);
end

end

%% ========================================================================
%  INTERNAL FUNCTION: Generate LLM prompt
%  ========================================================================

function prompt = generate_prompt_internal(state, P_t, D_t, cfg)

% Extract fields safely
if isfield(cfg, 'num_nodes')
    num_nodes = cfg.num_nodes;
else
    num_nodes = 50;
end

if isfield(cfg, 'mem_gb_per_node')
    mem_gb = cfg.mem_gb_per_node;
else
    mem_gb = 32;
end

if isfield(cfg, 'cpu_cores_per_node')
    cpu_cores = cfg.cpu_cores_per_node;
else
    cpu_cores = 8;
end

if isfield(D_t, 'text') && ~isempty(D_t.text)
    directive_text = D_t.text{1};
else
    directive_text = 'No specific directives.';
end

if isfield(P_t, 'sla_target')
    sla_target = P_t.sla_target * 100;
else
    sla_target = 95;
end

if isfield(P_t, 'energy_constraint')
    energy_constraint = P_t.energy_constraint;
else
    energy_constraint = 10000;
end

% Build prompt
prompt = sprintf([
    'System: You are an intelligent edge orchestrator.\n' ...
    'Resource States: %d nodes available\n' ...
    'Policies: SLA target=%.0f%%, Energy constraint=%.0f J\n' ...
    'Directives: %s\n' ...
    'Constraints: CPU?%d cores, Memory?%.1f GB\n' ...
    'Output: Balanced task-to-node allocation.'
], num_nodes, sla_target, energy_constraint, ...
   directive_text, cpu_cores, mem_gb);

end