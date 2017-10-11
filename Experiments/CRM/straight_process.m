function [y, fs] = straight_process(wavIn, dF0, dVTL, options)

[wavIn_path, wavIn_name, wavIn_ext] = fileparts(wavIn);
cache_path = fullfile(wavIn_path, options.cache_path);

wavOut = make_fname(wavIn, dF0, dVTL, cache_path);

if ~exist(wavOut, 'file') || options.force_rebuild_straight_output
    
    addpath(options.path.straight);
    
    
    if ~exist(cache_path, 'dir')
        mkdir(cache_path);
    end
    mat = fullfile(cache_path, [wavIn_name, '.straight.mat']);
    
    if exist(mat, 'file')
        if isnan(dF0) || isnan(dVTL)
            return
        end
        
        load(mat);
    else
        if verLessThan('matlab', '8')
            [x, fs] = wavread(wavIn);
        else
            [x, fs] = audioread(wavIn);
        end
        
        if fs~=options.fs
            x = resample(x, options.fs, fs);
            fs = options.fs;
        end
        
        [f0, ap] = exstraightsource(x, fs);

        sp = exstraightspec(x, f0, fs);
        x_rms = rms(x);

        save(mat, 'fs', 'f0', 'sp', 'ap', 'x_rms');
        
        if isnan(dF0) || isnan(dVTL)
            return
        end
    end
    
    f0 = f0 * 2^(dF0/12);

    p.frequencyAxisMappingTable = 2^(-dVTL/12);
    y = exstraightsynth(f0, sp, ap, fs, p);

    y = y/rms(y)*x_rms;
    if max(abs(y))>1
        warning('Output was renormalized for "%s".', wavOut);
        y = 0.98*y/max(abs(y));
    end
    
    if verLessThan('matlab', '8')
        wavwrite(y, fs, wavOut);
    else
        audiowrite(wavOut, y, fs);
    end
    
    rmpath(options.path.straight);
else
    if verLessThan('matlab', '8')
        [y, fs] = wavread(wavOut);
    else
        [y, fs] = audioread(wavOut);
    end
end

%===============================================================
function fname = make_fname(wav, dF0, dVTL, destPath)
    [~, name, ext] = fileparts(wav);
    fname = sprintf('%s_dF0%.2f_dVTL%.2f%s', name, dF0, dVTL, ext);
    fname = fullfile(destPath, fname);
