function plot_results(results, cfg)
%% ========================================================================
%  PLOT RESULTS: Generate all figures from the paper
%  ========================================================================

fprintf('Generating figures...\n');

% Figure 3: Average Latency
figure('Name', 'Figure 3: Average Latency', 'Position', [100, 100, 600, 400]);
datasets = {'alibaba', 'google_borg'};
colors = {'b', 'r'};
for d = 1:length(datasets)
    data = results.(datasets{d});
    latency = data.llm_orch.all_latency * 1000;  % Convert to ms
    histogram(latency, 20, 'FaceColor', colors{d}, 'EdgeColor', 'k', 'FaceAlpha', 0.7);
    hold on;
end
xlabel('Latency (ms)');
ylabel('Frequency');
legend('Alibaba', 'Google Borg');
title('Figure 3: Average Latency Distribution');
grid on;
saveas(gcf, './Results/Figure_3_Latency.png');

% Figure 4: SLA Compliance
figure('Name', 'Figure 4: SLA Compliance', 'Position', [100, 100, 600, 400]);
for d = 1:length(datasets)
    data = results.(datasets{d});
    sla = data.llm_orch.all_sla * 100;  % Convert to %
    histogram(sla, 20, 'FaceColor', colors{d}, 'EdgeColor', 'k', 'FaceAlpha', 0.7);
    hold on;
end
xlabel('SLA Compliance (%)');
ylabel('Frequency');
legend('Alibaba', 'Google Borg');
title('Figure 4: SLA Compliance Distribution');
grid on;
saveas(gcf, './Results/Figure_4_SLA.png');

% Figure 10: Comparison with TFSCM
figure('Name', 'Figure 10: Comparison with TFSCM', 'Position', [100, 100, 800, 500]);
metrics_names = {'Latency', 'SLA', 'Energy', 'Accuracy', 'Migration', 'Throughput', 'Utility'};
alibaba_llm = [results.alibaba.llm_orch.latency_mean*1000, ...
               results.alibaba.llm_orch.sla_mean*100, ...
               results.alibaba.llm_orch.energy_mean/1000, ...
               results.alibaba.llm_orch.accuracy_mean*100, ...
               results.alibaba.llm_orch.migration_mean, ...
               results.alibaba.llm_orch.throughput_mean, ...
               results.alibaba.llm_orch.utility_mean];

alibaba_tfscm = [210, 82, 8.2, 88, 0.18, 142, 0.75];  % Approximate from paper

bar_data = [alibaba_llm; alibaba_tfscm]';
bar(bar_data);
set(gca, 'XTickLabel', metrics_names);
legend('LLM-Orch', 'TFSCM');
ylabel('Value');
title('Figure 10: Comparison with TFSCM');
grid on;
saveas(gcf, './Results/Figure_10_TFSCM_Comparison.png');

% Figure 17: Ablation Study
figure('Name', 'Figure 17: Ablation Study', 'Position', [100, 100, 800, 500]);
subplot(1,3,1);
bar([1,2,3,4,5,6], [258.4, 238.6, 215.2, 235.8, 225.6, 208.7]);
set(gca, 'XTickLabel', {'w/o SemRP', 'w/o IGWA', 'w/o ExOD', 'w/o RAPO', 'w/o CFL', 'Full'});
ylabel('Latency (ms)');
title('(a) Latency');
grid on;

subplot(1,3,2);
bar([1,2,3,4,5,6], [78.5, 81.2, 88.5, 82.5, 85.0, 90.2]);
set(gca, 'XTickLabel', {'w/o SemRP', 'w/o IGWA', 'w/o ExOD', 'w/o RAPO', 'w/o CFL', 'Full'});
ylabel('SLA Compliance (%)');
title('(b) SLA Compliance');
grid on;

subplot(1,3,3);
bar([1,2,3,4,5,6], [0.65, 0.70, 0.85, 0.72, 0.75, 0.88]);
set(gca, 'XTickLabel', {'w/o SemRP', 'w/o IGWA', 'w/o ExOD', 'w/o RAPO', 'w/o CFL', 'Full'});
ylabel('System Utility');
title('(c) System Utility');
grid on;

saveas(gcf, './Results/Figure_17_Ablation.png');

fprintf('✓ All figures saved to ./Results/\n');
end