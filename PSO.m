function [allocation, schedule] = PSO(data, R_t, priority_weights, cfg)
%% ========================================================================
%  PSO: Particle Swarm Optimization for Task Scheduling
%  ========================================================================

num_tasks = data.num_tasks;
num_nodes = cfg.num_nodes;
duration = data.duration;

% Simplified PSO (for demonstration)
num_particles = 20;
num_iterations = 50;

% Initialize particles (each particle = allocation vector)
particles = randi(num_nodes, num_particles, num_tasks);
velocities = zeros(num_particles, num_tasks);

% Evaluate fitness (minimize makespan)
best_particle = particles(1,:);
best_fitness = inf;

for iter = 1:num_iterations
    for p = 1:num_particles
        % Calculate fitness (makespan)
        node_load = zeros(num_nodes, 1);
        for t = 1:num_tasks
            node_load(particles(p,t)) = node_load(particles(p,t)) + duration(t);
        end
        fitness = max(node_load);
        
        if fitness < best_fitness
            best_fitness = fitness;
            best_particle = particles(p,:);
        end
    end
    
    % Update particles (simplified)
    for p = 1:num_particles
        velocities(p,:) = 0.5 * velocities(p,:) + ...
                          0.3 * rand(1,num_tasks) .* (best_particle - particles(p,:));
        particles(p,:) = mod(round(particles(p,:) + velocities(p,:) - 1), num_nodes) + 1;
    end
end

% Best allocation
allocation = best_particle';
schedule = zeros(num_tasks, 1);
node_load = zeros(num_nodes, 1);
for t = 1:num_tasks
    schedule(t) = node_load(allocation(t));
    node_load(allocation(t)) = node_load(allocation(t)) + duration(t);
end

end