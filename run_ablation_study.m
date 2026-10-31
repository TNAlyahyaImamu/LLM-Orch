function results = run_ablation_study(data, cfg)
%% ========================================================================
%  run_ablation_study: Generate Table XIII (Ablation) and Figure 17
%  ========================================================================

cfg.num_nodes = 200;
num_runs = 10;  % Reduce for speed

variants = {'w/o SemRP', 'w/o IGWA', 'w/o ExOD', 'w/o RAPO', 'w/o CFL', 'Full LLM-Orch'};
results = struct();
results.variants = variants;

% Initialize metric arrays
latency = zeros(length(variants), 1);
sla = zeros(length(variants), 1);
energy = zeros(length(variants), 1);
utility = zeros(length(variants), 1);
throughput = zeros(length(variants), 1);

for v = 1:length(variants)
    fprintf('  Running %s...', variants{v});
    
    all_latency = zeros(num_runs, 1);
    all_sla = zeros(num_runs, 1);
    all_energy = zeros(num_runs, 1);
    all_utility = zeros(num_runs, 1);
    all_tp = zeros(num_runs, 1);
    
    for run = 1:num_runs
        rng(cfg.random_seed + run + v*1000);
        
        % Run with variant
        [state, R_t, P_t, D_t] = SCRC(data, cfg);
        
        % SemRP (with variant)
        if v == 1  % w/o SemRP
            allocation_plan = random_allocation(data, cfg);
            A_t = allocation_plan.matrix;
            prompt_semrp = 'Random allocation (no SemRP)';
        else
            [allocation_plan, A_t, prompt_semrp] = SemRP(state, P_t, D_t, cfg);
        end
        
        % IGWA (with variant)
        if v == 2  % w/o IGWA
            workflow_schedule = static_workflow(data, cfg);
            W_t = struct('schedule', workflow_schedule, 'status', 'static');
            prompt_igwa = 'Static workflow (no IGWA)';
        else
            [workflow_schedule, W_t, prompt_igwa] = IGWA(data, allocation_plan, D_t, cfg);
        end
        
        % ExOD (with variant)
        if v == 3  % w/o ExOD
            explanations = cell(data.num_tasks, 1);
            for t = 1:data.num_tasks
                explanations{t} = 'No explanation (ExOD disabled)';
            end
            X_t = struct('explanations', explanations);
            prompt_exod = 'No ExOD';
        else
            [explanations, X_t, prompt_exod] = ExOD(allocation_plan, workflow_schedule, P_t, D_t, cfg);
        end
        
        % RAPO (with variant)
        if v == 4  % w/o RAPO
            refined_prompt = 'Static prompt (no RAPO)';
            theta = [];
            reward = 0;
        else
            [refined_prompt, theta, reward] = RAPO(A_t, W_t, state, cfg);
        end
        
        % CFL (with variant)
        if v == 5  % w/o CFL
            new_state = state;
            feedback_signal = struct();
        else
            [new_state, feedback_signal] = CFL(state, R_t, W_t, D_t, cfg);
        end
        
        % Calculate metrics
        metrics = calculate_metrics(data, allocation_plan, workflow_schedule, ...
                                    A_t, W_t, state, cfg);
        
        all_latency(run) = metrics.latency * 1000;
        all_sla(run) = metrics.sla_compliance * 100;
        all_energy(run) = metrics.energy;
        all_utility(run) = metrics.system_utility;
        all_tp(run) = metrics.throughput;
    end
    
    latency(v) = mean(all_latency);
    sla(v) = mean(all_sla);
    energy(v) = mean(all_energy);
    utility(v) = mean(all_utility);
    throughput(v) = mean(all_tp);
    
    fprintf(' Latency=%.1fms, SLA=%.1f%%, Utility=%.2f\n', ...
            latency(v), sla(v), utility(v));
end

results.latency = latency;
results.sla = sla;
results.energy = energy;
results.utility = utility;
results.throughput = throughput;

end

function allocation_plan = random_allocation(data, cfg)
% Random allocation (w/o SemRP)
num_tasks = data.num_tasks;
num_nodes = cfg.num_nodes;
A_t = zeros(num_tasks, num_nodes);
for t = 1:num_tasks
    A_t(t, randi(num_nodes)) = 1;
end
allocation_plan = struct('matrix', A_t, 'num_tasks', num_tasks, 'num_nodes', num_nodes);
end

function workflow_schedule = static_workflow(data, cfg)
% Static workflow (w/o IGWA)
num_tasks = data.num_tasks;
workflow_schedule = struct();
workflow_schedule.task_order = (1:num_tasks)';
workflow_schedule.levels = ones(num_tasks, 1);
workflow_schedule.num_tasks = num_tasks;
end

function [allocation, schedule] = LLM_Orch_baseline(data, R_t, priority_weights, cfg)
% LLM-Orch as baseline for comparison
[state, ~, P_t, D_t] = SCRC(data, cfg);
[allocation_plan, ~, ~] = SemRP(state, P_t, D_t, cfg);
[workflow_schedule, ~, ~] = IGWA(data, allocation_plan, D_t, cfg);
allocation = allocation_plan.matrix;
schedule = workflow_schedule.task_order;
end