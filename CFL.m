function [new_state, feedback_signal] = CFL(state, R_t, W_t, D_t, cfg)
%% ========================================================================
%  CFL: Continuous Feedback Loop (Section 3.6)
%  ========================================================================

% Aggregated feedback state (Eq. 19)
F_t = struct();
F_t.R = R_t;
F_t.W = W_t;
F_t.O = D_t;

% Exponential smoothing (Eq. 21)
persistent F_prev;
lambda = cfg.hp.lambda;

% ===== FIX: Initialize F_prev if empty or if dimensions changed =====
if isempty(F_prev)
    F_prev = F_t;
else
    % Check if dimensions match
    if length(F_prev.R.cpu_available) ~= length(R_t.cpu_available)
        % Dimensions changed, reset F_prev
        F_prev = F_t;
    end
end

% ===== FIX: Ensure both vectors have same length =====
% Get lengths
len_cpu = length(R_t.cpu_available);
len_cpu_prev = length(F_prev.R.cpu_available);
len_mem = length(R_t.mem_available);
len_mem_prev = length(F_prev.R.mem_available);

% Align dimensions if needed (use current dimensions)
if len_cpu ~= len_cpu_prev
    % If previous is smaller, pad with zeros; if larger, truncate
    if len_cpu > len_cpu_prev
        cpu_prev_extended = [F_prev.R.cpu_available; zeros(len_cpu - len_cpu_prev, 1)];
    else
        cpu_prev_extended = F_prev.R.cpu_available(1:len_cpu);
    end
else
    cpu_prev_extended = F_prev.R.cpu_available;
end

if len_mem ~= len_mem_prev
    if len_mem > len_mem_prev
        mem_prev_extended = [F_prev.R.mem_available; zeros(len_mem - len_mem_prev, 1)];
    else
        mem_prev_extended = F_prev.R.mem_available(1:len_mem);
    end
else
    mem_prev_extended = F_prev.R.mem_available;
end

% ===== Smoothed feedback with aligned dimensions =====
feedback_signal = struct();
feedback_signal.R_cpu = lambda * R_t.cpu_available + (1 - lambda) * cpu_prev_extended;
feedback_signal.R_mem = lambda * R_t.mem_available + (1 - lambda) * mem_prev_extended;
feedback_signal.timestamp = now;

% Update contextual state
new_state = state;

if isfield(state, 'iteration')
    new_state.iteration = state.iteration + 1;
else
    new_state.iteration = 1;
end

new_state.feedback = feedback_signal;

% Regenerate semantic prompts
new_state.updated_prompts = generate_updated_prompts(new_state, cfg);

% Update workflow adaptation
new_state.updated_workflow = W_t;

% Store for next iteration
F_prev = F_t;

end

function prompts = generate_updated_prompts(state, cfg)
%% ========================================================================
%  Generate updated prompts based on feedback
%  ========================================================================

prompts = struct();

if isfield(state, 'iteration')
    iter_num = state.iteration;
else
    iter_num = 1;
end

if isfield(state, 'updated_workflow') && isfield(state.updated_workflow, 'status')
    workflow_status = state.updated_workflow.status;
else
    workflow_status = 'unknown';
end

if isfield(state, 'feedback')
    if isfield(state.feedback, 'R_cpu')
        cpu_feedback = state.feedback.R_cpu(1);
    else
        cpu_feedback = 0.5;
    end
    if isfield(state.feedback, 'R_mem')
        mem_feedback = state.feedback.R_mem(1);
    else
        mem_feedback = 0.5;
    end
else
    cpu_feedback = 0.5;
    mem_feedback = 0.5;
end

prompts.semrp = sprintf(...
    ['Updated SemRP prompt based on feedback.\n' ...
     'Iteration: %d\n' ...
     'Current feedback: CPU=%.2f, Memory=%.2f\n' ...
     'Recommendation: Re-optimize allocation based on recent performance.'], ...
    iter_num, cpu_feedback, mem_feedback);

prompts.igwa = sprintf(...
    ['Updated IGWA prompt based on feedback.\n' ...
     'Iteration: %d\n' ...
     'Current workflow status: %s\n' ...
     'Recommendation: Adapt task ordering based on resource constraints.'], ...
    iter_num, workflow_status);

end