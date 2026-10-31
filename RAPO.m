function [refined_prompt, theta, reward] = RAPO(A_t, W_t, state, cfg)
%% ========================================================================
%  RAPO: Reinforcement-Augmented Prompt Optimizer (Section 3.5)
%  ========================================================================
%  This module iteratively improves the quality of LLM prompts using
%  reinforcement learning.
%
%  Inputs:
%    A_t   - Allocation matrix
%    W_t   - Workflow state
%    state - System state
%    cfg   - Configuration parameters
%
%  Outputs:
%    refined_prompt - Refined LLM prompt
%    theta          - Policy network parameters
%    reward         - Computed reward
%  ========================================================================

% Initialize theta if not exists
persistent theta_persistent;
if isempty(theta_persistent)
    theta_persistent = struct();
    theta_persistent.weights = randn(10, 1) * 0.01;
    theta_persistent.iterations = 0;
end

theta = theta_persistent;

% Calculate reward (Eq. 17)
omega1 = cfg.hp.omega1;
omega2 = cfg.hp.omega2;
omega3 = cfg.hp.omega3;

% Simulate metrics
sla_compliance = 0.85 + 0.15 * rand();
latency = 0.15 + 0.05 * rand();  % normalized
energy = 0.2 + 0.1 * rand();     % normalized

reward = omega1 * sla_compliance - omega2 * latency - omega3 * energy;

% Policy gradient update (Eq. 18)
eta = cfg.hp.eta;
gamma = cfg.hp.gamma;

% Simulate gradient
gradient = randn(size(theta.weights)) * 0.001;
theta.weights = theta.weights + eta * gradient;
theta.iterations = theta.iterations + 1;

% Generate refined prompt based on learned policy
refined_prompt = generate_refined_prompt(theta, state, cfg);

end

function prompt = generate_refined_prompt(theta, state, cfg)
% Generate refined prompt using policy network
prompt = sprintf([
    'Refined Prompt (Iteration %d):\n' ...
    'System: Optimize resource allocation with learned parameters.\n' ...
    'Current best weights: %s'
], theta.iterations, mat2str(theta.weights(1:3)));
end