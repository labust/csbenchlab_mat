function load_environment(env_name, varargin)
    
    pa = @BlockHelpers.path_append;
    save_folder_name = 'saves';

    now_t = int64(posixtime(datetime('now', 'TimeZone','local')));
    file_path = which(strcat(env_name, '.slx'));

    if isempty(file_path)
        error(strcat('Failed to load environment. Environment "', ...
            env_name, '" does not exist on path.'));
    end
    folder_path = fileparts(file_path);
    saves_folder_path = pa(folder_path, save_folder_name);

    if nargin > 1
        save_name = varargin{1};
        curr_save = pa(saves_folder_path, save_name);
    else
        
        l_dir = dir(saves_folder_path);
        m = 0; % max date
        idx = 0;
        for i=1:length(l_dir)
            d = l_dir(i);
            if strcmp(d.name, '.') || strcmp(d.name, '..')
                continue
            end
            if d.datenum > m
                m = d.datenum;
                idx = i;
            end
        end

        if idx <= 0
            error('Cannot load environment. No save exists');
        end

        newest_dir = l_dir(idx);
        curr_save = pa(saves_folder_path, newest_dir.name);
    end

    if ~exist(curr_save, 'dir')
        error(strcat('Cannot load environment. Folder ', curr_save, "does not exist"));
    end

    % load variable names from environment slx
    loaded = load(pa(folder_path, 'autogen', strcat(env_name, '.mat')));
    info = loaded.env_info;
    blocks = loaded.blocks;

    saved_cfg = readstruct(pa(curr_save, 'config.json'), "FileType", "json");
    env_cfg = readstruct(pa(folder_path, 'config.json'), "FileType", "json");

    are_equal = isequaln(saved_cfg, env_cfg);
    
    override = 0;
    if ~are_equal    
        answer = questdlg(['Current environment does not match the saved environment. ' ...
            'Do you want to override the current environment?']);
        
        if strcmp(answer, 'Yes')
            override = 1;
        end
    end

    if override
        delete(pa(folder_path, strcat(env_name, '.slx')));
        delete(pa(folder_path, 'config.json'));

        copyfile(pa(curr_save, strcat(env_name, '_bckp.slx')), ...
            pa(folder_path, strcat(env_name, '.slx')));
        copyfile(pa(curr_save, 'config.json'), pa(folder_path, 'config.json'));   
    end
    
    % load vars
    path = pa(curr_save, 'vars.mat');
    evalin('caller', strcat("load('", path, "');"));
    
    % load scenarios
    path = pa(folder_path, 'autogen', strcat(env_name, '_scenarios.mat'));
    evalin('caller', strcat("load('", path, "');"));

    % load plots
    path = pa(folder_path, 'autogen', strcat(env_name, '_plots.mat'));
    evalin('caller', strcat("load('", path, "');"));
    open_system(strcat(env_name, '.slx'));


end