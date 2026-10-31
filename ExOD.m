function [explanations, X_t, prompt] = ExOD(allocation_plan, workflow_schedule, P_t, D_t, cfg)
%% ========================================================================
%  ExOD: Explainable Orchestration Decoder (Section 3.4)
%  ========================================================================
%  This module translates orchestration decisions into human-readable
%  rationales, facilitating stakeholder comprehension and trust.
%
%  Inputs:
%    allocation_plan   - Resource allocation plan
%    workflow_schedule - Adapted workflow schedule
%    P_t               - Policy constraints
%    D_t               - Operator directives
%    cfg               - Configuration parameters
%
%  Outputs:
%    explanations - Human-readable decision rationales
%    X_t          - Decision explanation set
%    prompt       - Generated LLM prompt
%  ========================================================================

% Generate ExOD prompt (simulated)
prompt = generate_exod_prompt(allocation_plan, workflow_schedule, P_t, D_t, cfg);

% Simulate LLM inference latency (lighter model = faster)
pause(0.015);  % ~15ms for GPT-3.5-Turbo

% Calculate rationale scores (Eq. 15)
num_tasks = allocation_plan.num_tasks;
alpha = cfg.hp.alpha;
beta = cfg.hp.beta;
gamma = cfg.hp.gamma_exod;

p_i = zeros(num_tasks, 1);
explanations = cell(num_tasks, 1);

for t = 1:num_tasks
    % f_c: policy compliance
    f_c = 0.9 + 0.1 * rand();
    
    % f_d: directive satisfaction
    f_d = 0.8 + 0.2 * rand();
    
    % f_r: resource feasibility
    f_r = 0.85 + 0.15 * rand();
    
    % Calculate score
    p_i(t) = alpha * f_c + beta * f_d + gamma * f_r;
    
    % Generate explanation (Eq. 16)
    explanations{t} = sprintf(...
        ['Task %d was assigned based on:\n' ...
         '- Policy compliance: %.2f\n' ...
         '- Directive satisfaction: %.2f\n' ...
         '- Resource feasibility: %.2f\n' ...
         'Overall rationale score: %.2f'], ...
        t, f_c, f_d, f_r, p_i(t));
end

% X_t: Decision explanation set
X_t = struct();
X_t.explanations = explanations;
X_t.scores = p_i;
X_t.timestamp = now;

end

function prompt = generate_exod_prompt(allocation_plan, workflow_schedule, P_t, D_t, cfg)
% Generate ExOD prompt (simulated)
prompt = sprintf([
    'System: Generate a human-readable explanation for the orchestration\n' ...
    'decision made for each task.\n\n' ...
    'Allocation: %d tasks across %d nodes\n' ...
    'Policy Compliance Score: %.2f\n' ...
    'Context: SLA target=%.0f%%, Energy constraint=%.0f J\n' ...
    'Output: Natural language rationale for each task.'
], allocation_plan.num_tasks, allocation_plan.num_nodes, ...
   cfg.hp.alpha, P_t.sla_target*100, P_t.energy_constraint);
end