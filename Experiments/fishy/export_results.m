function export_filename = export_results(fmt)

% PICKA Fishy: Process the raw result .mat files into sqlite, csv or xls.
% Note: the training phase is not filled in the table.

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2017-12-02
% CNRS UMR 5292, FR | University of Groningen, UMCG, NL
%--------------------------------------------------------------------------

ref_options = fishy_options();

lst = dir(fullfile(ref_options.result_path, [ref_options.result_prefix, '*.mat']));
files = { lst.name };

last_filedate = most_recent_filedate(lst);

switch fmt
    case 'sqlite'
        export_filename = fullfile(ref_options.result_path, [ref_options.result_prefix, 'db.sqlite']);
        
        %-- Check if we need to regenerate the database
        if exist(export_filename, 'file') & last_filedate < get_filedate(export_filename)
            fprintf('The database file is more recent that the most recent data file, so we are not recreating the database.\n');
            fprintf('To force the creation of the database, delete the sqlite file "%s".\n', export_filename);
            return
        end
        
        %-- Get some tools
        addpath(ref_options.path.mksqlite);
        addpath(ref_options.path.tools);
        
        db = mksqlite('open', export_filename);
        mksqlite('PRAGMA journal_mode=OFF');
        
        %-- Tables creation
        mksqlite('DROP TABLE IF EXISTS results');
        mksqlite(['CREATE TABLE IF NOT EXISTS results '...
                  '('...
                  'id INTEGER PRIMARY KEY AUTOINCREMENT, '...
                  'subject TEXT, '...
                  'ref_f0 REAL /* Hz */, '...
                  'dir_f0 REAL /* Hz */, '...
                  'ref_ser REAL /* ratio */, '...
                  'dir_ser REAL /* ratio */, '...
                  'ref_voice TEXT, '...
                  'dir_voice TEXT, '...
                  'threshold FLOAT /* semitones */,'...
                  'threshold_f0 FLOAT /* semitones */, '...
                  'threshold_vtl FLOAT /* semitones */, '...
                  'sd FLOAT, '....
                  'response_datetime TEXT, '...
                  'i INTEGER'...
                  ')']);
        
        %-- Filling the table

        which_threshold = 'last_6_tp';
        %which_threshold = 'all';

        for i=1:length(files)

            fprintf('=====> Processing %s...\n', files{i});
            load(fullfile(ref_options.result_path, files{i}));
            
            all_phases = fieldnames(results);
            
            for i_phase = 1:length(all_phases)
                phase = all_phases{i_phase};
                if startswith(phase, 'training')
                    continue;
                end

                for ic=1:length(results.(phase).conditions)

                    c = results.(phase).conditions(ic);

                    a = c.att(end);

                    if isfield(a, 'threshold') && ~isnan(a.threshold)

                        t = a.responses(1).trial;

                        r = struct();

                        r.subject = options.subject_name;

                        r.ref_f0 = options.(phase).voices(t.ref_voice).f0;
                        r.dir_f0 = options.(phase).voices(t.dir_voice).f0;
                        r.ref_ser = options.(phase).voices(t.ref_voice).ser;
                        r.dir_ser = options.(phase).voices(t.dir_voice).ser;
                        r.ref_voice = options.(phase).voices(t.ref_voice).label;
                        r.dir_voice = options.(phase).voices(t.dir_voice).label;

            %             r.vocoder = t.vocoder;
            %             if r.vocoder>0
            %                 r.vocoder_name = options.vocoder(r.vocoder).label;
            %                 r.vocoder_description = options.vocoder(r.vocoder).description;
            %             end    

                        rewt = regexp(which_threshold, 'last_(\d+)_tp', 'tokens');
                        if isempty(rewt)
                            i_tp = a.diff_i_tp;    
                            r.threshold = a.threshold;
                        else
                            ntp = str2double(rewt{1});
                            i_nz = find(a.steps~=0);
                            i_d  = find(diff(sign(a.steps(i_nz)))~=0);
                            i_tp = i_nz(i_d)+1;
                            i_tp = [i_tp, length(a.differences)];
                            i_tp = i_tp(end-(ntp-1):end);

                            r.threshold = mean(a.differences(i_tp));
                        end

                        u_f0  = 12*log2(options.(phase).voices(t.dir_voice).f0 / options.(phase).voices(t.ref_voice).f0);
                        u_ser = 12*log2(options.(phase).voices(t.dir_voice).ser / options.(phase).voices(t.ref_voice).ser);
                        u = [u_f0, u_ser];
                        u = u / sqrt(sum(u.^2));

                        r.threshold_f0 = r.threshold*u(1);
                        r.threshold_ser = r.threshold*u(2);

                        r.response_datetime = datestr(a.responses(1).timestamp, 'yyyy-mm-dd HH:MM:SS');
                        r.sd = a.sd;
                        r.i = ic;

                        mksqlite_insert(db, 'results', r);
                    end

                end % conditions
                
            end % phases
            
        end % files

        mksqlite(db, 'close');
        
        rmpath(ref_options.path.mksqlite);
        rmpath(ref_options.path.tools);
        
    case {'csv', 'xls'}
        export_filename = fullfile(ref_options.result_path, [ref_options.result_prefix, 'db.', fmt]);
        
        db_filename = export_results('sqlite');
        
        %[c, s] = system(sprintf('python ../../Resources/lib/python/sqlite_to_table.py "%s" "%s"', db_filename, export_filename));
        append(py.sys.path, '../../Resources/lib/python');
        mod = py.importlib.import_module('sqlite_to_table');
        py.reload(mod);
        c = py.sqlite_to_table.main(py.list({db_filename, export_filename}));
        
        if c~=0
            error('Excution of the Python sqlite_to_table.py failed...');
        end
    otherwise
        error('Export format "%s" is not implemented.', fmt);
end


% %==========================================================================
% function md = md5(msg)
% 
% MD = java.security.MessageDigest.getInstance('md5');
% md = typecast(MD.digest(uint8(msg)), 'uint8');
% md = lower(reshape(dec2hex(md)', 1, []));
% 
% %==========================================================================
% function md = md5_file(filename)
% 
% fid = fopen(filename, 'r');
% md = md5(fread(fid));
% fclose(fid);

%==========================================================================
function fdate = most_recent_filedate(lst)

fdate = max([lst.datenum]);

function fdate = get_filedate(filename)

fileinfo = dir(filename);
fdate = fileinfo(1).datenum;
