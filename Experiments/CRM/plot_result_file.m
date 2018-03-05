function f1 = plot_result_file(filename)

f = load(filename);

%------ Training
%{
figure()

d = f.results.training.responses;

xticklabel = {};
for i=1:length(d)
    r = d(i);
    colour_correct(i) = r.colour_index == r.trial.target.colour_index;
    number_correct(i) = r.number == r.trial.target.number;
    xticklabel{i} = sprintf('%i: TMR %.0f dF0=%.1fst, dVTL=%.1fst', i, r.trial.tmr, r.trial.voice.dF0, r.trial.voice.dVTL);
end

bar([colour_correct; number_correct]', 'stacked')

ylabel('Score (colour | number)')
set(gca, 'XTickLabel', xticklabel, 'XTickLabelRotation', 90)
title(sprintf('%s :: Training', f.options.subject_name))
%}

%------ Test
f1 = figure();
d = f.results.test.responses;

dF0s = [];
dVTLs = [];
for i = 1:length(d)
    r = d(i);
    %dF0s = unique([f.options.voices.dF0]);
    dF0s = unique([dF0s, [r.trial.voice.dF0]]);
    %dVTLs = unique([f.options.voices.dVTL]);
    dVTLs = unique([dVTLs, [r.trial.voice.dVTL]]);
end

score = nan(length(f.options.tmrs), length(dF0s), length(dVTLs));
% for i_tmr = 1:length(options.tmrs)
%     tmr = options.tmrs(i_tmr);  
%     for i_dF0 = 1:length(dF0s)
%         dF0 = dF0s(i_dF0);
%         for i_dVTL = 1:length(dVTLs)
%             dVTL = dVTLs(i_dVTL);
%             score(i_tmr, i_dF0, idVTL) = NaN;
%         end
%     end
% end

for i = 1:length(d)
    r = d(i);
    i_tmr = find(r.trial.tmr == f.options.tmrs);
    i_dF0 = find(r.trial.voice.dF0 == dF0s);
    i_dVTL = find(r.trial.voice.dVTL == dVTLs);
    if isnan(score(i_tmr, i_dF0, i_dVTL))
        score(i_tmr, i_dF0, i_dVTL) = r.correct + 1i;
    else
        % We use complex numbers to store the sum of scores (real part) and the number
        % of repetitions for each condition (imaginary part)
        score(i_tmr, i_dF0, i_dVTL) = real(score(i_tmr, i_dF0, i_dVTL))+r.correct + (imag(score(i_tmr, i_dF0, i_dVTL)) + 1)*1i;
    end
end

score = real(score) ./ imag(score);

for i_tmr = 1:length(f.options.tmrs)
    subplot(1, length(f.options.tmrs), i_tmr)
    
    for i_dVTL = 1:length(dVTLs)
        plot(dF0s, score(i_tmr, :, i_dVTL)/2, 'o-', 'DisplayName', sprintf('dVTL = %.1f st', dVTLs(i_dVTL)))
        hold on
    end
    hold off
    
    ylim([0, 1])
    xlabel('dF0 (st)')
    ylabel('Score')
    title(sprintf('%s :: TMR %.1f dB', f.options.subject_name, f.options.tmrs(i_tmr)))
    legend('show');
    legend('Location', 'best');
end

set(gcf, 'PaperPosition', [0,0,6,4]*1.5)
print(gcf, strrep(filename, '.mat', '.png'), '-dpng', '-r300');

