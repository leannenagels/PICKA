function save_results()

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2018-02-05
% CNRS UMR 5292, FR | University of Groningen, UMCG, NL
%--------------------------------------------------------------------------

PICKA = picka_definition();

addpath('../Resources/lib/MatlabCommonTools');

if exist('.default_save_dir.mat', 'file')
    s = load('.default_save_dir.mat');
    save_dir = s.save_dir;
else
    save_dir = fullfile(getHome(), 'Google Drive');
end

fprintf('Select the destination directory to upload the results.\n');
fprintf('This should be the "Results" directory of the Google Drive PICKA directory.\n');

save_dir = uigetdir(save_dir, 'PICKA Results (Google Drive)');

if length(save_dir)==1 & save_dir==0
    error('Aborted.');
else
    save('.default_save_dir.mat', 'save_dir');
end

dst = save_dir;

for i=1:length(PICKA)
    fprintf('\n----------- Exporting results from %s\n', PICKA(i).folder);
    if ~exist(fullfile(dst, PICKA(i).folder), 'dir')
        mkdir(fullfile(dst, PICKA(i).folder));
    end
    if ~exist(fullfile(PICKA(i).folder, 'results'), 'dir')
        fprintf('No results yet.\n');
        continue;
    end
    
    ref_cd = pwd();
    try
        cd(PICKA(i).folder);
        fx_options = str2func([PICKA(i).prefix, '_options']);
        options = fx_options();
        export_results('csv');
        cd('..');
    catch e
        cd(ref_cd);
        e.rethrow();
    end
    fprintf('Copying to Google Drive...\n');
    for ext = {'mat', 'csv', 'sqlite'}
        pattern = fullfile(PICKA(i).folder, options.result_path, [options.result_prefix, '*.', ext{1}]);
        fprintf('   %s', pattern);
        lst = dir(pattern);
        fprintf(': %d file(s) found.\n', length(lst));
        for k=1:length(lst)
            a = fullfile(PICKA(i).folder, options.result_path, lst(k).name);
            b = fullfile(dst, PICKA(i).folder);
            fprintf('      %s -> %s\n', a, b);
            copyfile(a, b);
        end
    end
    
end

fprintf('\nDone.\n');

rmpath('../Resources/lib/MatlabCommonTools');