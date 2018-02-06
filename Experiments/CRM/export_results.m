function export_filename = export_results(fmt)

% PICKA CRM: Process the raw result .mat files into sqlite, csv or xls.
% Note: the training phase is not filled in the table.

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2017-12-02
% CNRS UMR 5292, FR | University of Groningen, UMCG, NL
%--------------------------------------------------------------------------

if nargin<1
    fmt = 'sql';
end

ref_options = expe_options();

lst = dir(fullfile(ref_options.result_path, [ref_options.result_prefix, '*.mat']));
files = { lst.name };

last_filedate = most_recent_filedate(lst);

switch fmt
    case {'sqlite', 'sql'}
        export_filename = fullfile(ref_options.result_path, [ref_options.result_prefix, 'db.sqlite']);
        
        %-- Check if we need to regenerate the database
        if exist(export_filename, 'file') && last_filedate < get_filedate(export_filename)
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
        mksqlite('DROP TABLE IF EXISTS responses');
        mksqlite(['CREATE TABLE IF NOT EXISTS responses '...
                  '('...
                  'id INTEGER PRIMARY KEY AUTOINCREMENT, '...
                  'subject TEXT, '...
                  'dF0 REAL /* semitones */, '...
                  'dVTL REAL /* semitones */, '...
                  'target_colour TEXT, '...
                  'target_number INTEGER, '...
                  'target_callsign TEXT, '...
                  'target_soundfile TEXT, '...
                  'tmr REAL, '...
                  'image TEXT, '...
                  'i_repeat INTEGER, '...
                  'correct INTEGER, '...
                  'response_colour TEXT, '...
                  'response_number INTEGER, '...
                  'response_time REAL /* seconds */, '...
                  'response_datetime TEXT, '...
                  'i INTEGER'...
                  ')']);
        
        %-- Filling the table

        for i=1:length(files)

            fprintf('=====> Processing %s...\n', files{i});
            dat = load(fullfile(ref_options.result_path, files{i}));
            
            if ~isfield(dat, 'results')
                fprintf('No results in %s.\n', files{i});
                continue;
            end
            
            results = dat.results;
            all_phases = fieldnames(results);
            
            for i_phase = 1:length(all_phases)
                phase = all_phases{i_phase};
                if startswith(phase, 'training')
                    continue;
                end

                for ir=1:length(results.(phase).responses)

                    resp = results.(phase).responses(ir);

                    r = struct();

                    r.subject = options.subject_name;

                    r.dF0 = resp.trial.voice.dF0;
                    r.dVTL = resp.trial.voice.dVTL;
                    r.target_colour = resp.trial.target.colour;
                    r.target_number = resp.trial.target.number;
                    r.target_callsign = resp.trial.target.call_sign;
                    r.target_soundfile = resp.trial.target.soundfile;
                    r.tmr = resp.trial.tmr;
                    r.image = resp.trial.image;
                    r.i_repeat = resp.trial.i_repeat;
                    r.correct = resp.correct;
                    r.response_colour = resp.colour;
                    r.response_number = resp.number;
                    
                    r.response_datetime = resp.response_datetime;
                    r.response_time = resp.response_time;
                    
                    r.i = ir;

                    mksqlite_insert(db, 'responses', r);

                end % responses
                
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
