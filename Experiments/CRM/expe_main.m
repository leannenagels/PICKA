function expe_main(options, phase)

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@mrc-cbu.cam.ac.uk> - 2010-03-16
% Medical Research Council, Cognition and Brain Sciences Unit, UK
%
% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2017-08-06
% CNRS UMR 5292, FR | University of Groningen, UMCG, NL
%--------------------------------------------------------------------------

% Reminder that volume must be adjusted
warndlg('Make sure the volume has been adjusted to "Maximum"', options.experiment_label);

%---------------------------------------------------------------

results = struct();
load(options.res_filename); % options, expe, results

h = expe_gui(options, phase);

%---------------------------------------------------------------

set(h.waitbar_legend, 'String', phase);
drawnow()

nbreak = 0;
starting = 1;

%------------------- MAIN LOOP ------------------------
while mean([expe.( phase ).trials.done])~=1
    
    if starting
        opt = char(questdlg(sprintf('Ready to start the %s?', phase), options.experiment_label,'Go','Cancel','Go'));
        switch lower(opt)
            case 'cancel'
                break
        end
        starting = 0;
    end
    
    
    nbreak = nbreak+1;
    if nbreak>options.(phase).block_size
        nbreak = 0;
        opt = char(questdlg(sprintf('Take a short break...\nThen would you like to continue or stop?'), options.experiment_label,'Continue','Stop','Continue'));
        switch lower(opt)
            case 'stop'
                break
        end
    end
    
    
    % Find first trial not done
    i = find([expe.( phase ).trials.done]==0);
    i = min(i);
    
    trial = expe.( phase ).trials(i);
    
    [xOut, fs, info] = expe_make_stim(options, trial);
    
    xOut = xOut*10^(options.gain/20);
    
    m = max(abs(xOut));
    if m>.98
        xOut = xOut / m * .98;
        warning('xOut was rescaled to avoid clipping by a factor %.2f', .98/m);
    end
    
    set(gcf, 'CurrentAxes', h.waitbar);
    fill([0 1 1 0] * mean([expe.( phase ).trials.done]), [0 0 1 1], 'r', 'FaceColor', [.7, .3, 0]);
    xlim([0, 1]);
    ylim([0, 1]);
    set(h.waitbar, 'XTick', [], 'YTick', []);
    set(h.waitbar_legend, 'String', sprintf('%s: %d/%d', phase, sum([expe.( phase ).trials.done])+1, length([expe.( phase ).trials.done])));
    drawnow();
    
    set(gcf, 'CurrentAxes', h.grid);
    
    player = audioplayer(xOut, fs, 24);
    playblocking(player);
    
    %--- Get Response
    
    tic();
    
    ok = 0;
    while ~ok
        p = [-1, -1];
        k = waitforbuttonpress();
        p = get(h.grid, 'CurrentPoint');
        p = p(1, 1:2);

        if p(1)>0 && p(1)<options.n_numbers && p(2)>0 && p(2)<options.n_colours
            ok = 1;
        end
    end
    
    response.response_time = toc();
    response.response_datetime = datestr(now(), 31);

    p = ceil(p);
    response.number_index = p(1);
    response.number = options.target_corpus.numbers(response.number_index);
    response.colour_index = p(2);
    response.colour = options.target_corpus.colours{p(2)};

    for k=1:1
        set(h.t(p(2), p(1)), 'FontSize', h.fntsz+5)
        drawnow();
        pause(.1);
        set(h.t(p(2), p(1)), 'FontSize', h.fntsz)
        drawnow();
        pause(.1);
    end
    
    response.correct = (response.number == trial.target.number) + (response.colour_index == trial.target.colour_index);
    response.info = info;
    response.trial = trial;
    
    if trial.visual_feedback == 1
        % Give feedback
        
        for k=1:3
            %set(h.t(info.colour_index, info.number_index), 'Color', feedback_colors{(response.correct>0)+1}, 'FontSize', fntsz+5);
            set(h.t(trial.target.colour_index, trial.target.number_index), 'FontSize', h.fntsz+7);
            drawnow();
            pause(.1);
            set(h.t(trial.target.colour_index, trial.target.number_index), 'FontSize', h.fntsz)
            drawnow();
            pause(.1);
        end
        %set(h.t(info.colour_index, info.number_index), 'Color', feedback_colors{(response.correct>0)+1}, 'FontSize', fntsz+5);
        set(h.t(trial.target.colour_index, trial.target.number_index), 'FontSize', h.fntsz+7);
        drawnow();
        
    end
    
    if trial.visual_feedback == 1
        set(h.t(trial.target.colour_index, trial.target.number_index), 'FontSize', h.fntsz)
        drawnow();
    end
    
    if ~isfield(results, phase)
        results.( phase ).responses = orderfields( response );
    else
        results.( phase ).responses(end+1) = orderfields( response );
    end
    
    expe.( phase ).trials(i).done = 1;
    
    save(options.res_filename, 'options', 'expe', 'results')
    
    %report_status(options.subject_name, phase, sum([expe.( phase ).trials.done])+1, length([expe.( phase ).trials.done]));
    
    pause(1);
    
end

if mean([expe.( phase ).trials.done])==1
    msgbox(sprintf('The "%s" phase is finished. Thank you!', phase), options.experiment_label, 'warn');
end

close all

%--------------------------------------------------------------------------
% function report_status(subj, phase, i, n)
% 
% try
%     fd = fopen('T:\Etienne\Experiments\2011-02 - Zebra 10 - LF cue\results\status.txt', 'w');
%     fprintf(fd, '%s : %s : %d/%d\r\n', subj, phase, i, n);
%     fclose(fd);
% catch ME
% end
