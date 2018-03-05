function export_filename = export_results(fmt)

% PICKA Gender: Process the raw result .mat files into sqlite, csv or xls.
% Note: the training phase is not filled in the table.

%--------------------------------------------------------------------------
% Etienne Gaudrain <etienne.gaudrain@cnrs.fr> - 2017-12-02
% CNRS UMR 5292, FR | University of Groningen, UMCG, NL
%--------------------------------------------------------------------------

ref_options = gender_options();

lst = dir(fullfile(ref_options.result_path, [ref_options.result_prefix, '*.mat']));
files = { lst.name };

last_filedate = most_recent_filedate(lst);

switch fmt
    case 'sqlite'
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
                  'df0 REAL /* semitones */, '...
                  'dvtl REAL /* semitones */, '...
                  'word TEXT,'...
                  'face TEXT /* the face image that was presented */, '...
                  'face_gender TEXT /* the gender of that face */, '...
                  'response_same_different TEXT /* the gender of image and sound are same */, '...
                  'response TEXT /* the response in the form of gender */, '...
                  'response_datetime TEXT, '...
                  'response_time REAL, '...
                  'i INTEGER'...
                  ')']);
        
        %-- Filling the table
      
        for i=1:length(files)

            fprintf('=====> Processing %s...\n', files{i});
            load(fullfile(ref_options.result_path, files{i}));
            
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
                    r.df0 = resp.trial.f0;
                    r.dvtl = resp.trial.vtl;
                    r.word = resp.trial.word;
                    r.face = resp.trial.face;
                    r.face_gender = resp.trial.face_gender;
                    switch resp.button_clicked_label
                        case 'buttonright'
                            r.response_same_different = 'same';
                            r.response = resp.trial.face_gender;
                        case 'buttonwrong'
                            r.response_same_different = 'different';
                            if strcmp(resp.trial.face_gender, options.test.face_genders{1})
                                r.response = options.test.face_genders{2};
                            elseif strcmp(resp.trial.face_gender, options.test.face_genders{2})
                                r.response = options.test.face_genders{1};
                            end
                    end
                    
                    r.response_datetime = datestr(resp.timestamp, 'yyyy-mm-dd HH:MM:SS');
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
