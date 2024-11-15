function save_environment(env_name, varargin)
    
    pa = @BlockHelpers.path_append;
    save_folder_name = 'saves';

    now_t = int64(posixtime(datetime('now', 'TimeZone','local')));
    now_t_str = string(now_t);

    file_path = which(strcat(env_name, '.slx'));

    if isempty(file_path)
        error(strcat('Failed to save environment. Environment "', ...
            env_name, '" does not exist on path.'));
    end
    folder_path = fileparts(file_path);
    saves_folder_path = pa(folder_path, save_folder_name);

    if ~exist(saves_folder_path, 'dir')
        mkdir(saves_folder_path)
    end

    if nargin > 1
        save_name = varargin{1};
        curr_save = pa(saves_folder_path, save_name);
        if exist(curr_save, 'dir')
            curr_save = strcat(curr_save, '_', now_t_str);
        end
    else
        curr_save = pa(saves_folder_path, env_name);
        curr_save = strcat(curr_save, '_', now_t_str);
    end
    


    if ~exist(curr_save, 'dir')
        mkdir(curr_save)
    end

    % load variable names from environment slx
    loaded = load(pa(folder_path, 'autogen', strcat(env_name, '.mat')));
    info = loaded.env_info;
    blocks = loaded.blocks;

    first_sys = blocks.systems.systems(1);
    handle = getSimulinkBlockHandle(first_sys.Path);

    sys_values = get_param(handle, 'MaskValues');

    if nargin > 2
        variables_to_save = varargin{2};
    else
        variables_to_save = {};
    end
    variables_to_save{end+1} = sys_values{:};

    for i=1:length(blocks.controllers)
        c = blocks.controllers(i);
        for j=1:length(c.Components)
            % save mask parameters
            handle = getSimulinkBlockHandle(c.Components(j).Path);
            c_values = get_param(handle, 'MaskValues');
            vis = get_param(handle, 'MaskVisibilities');
            for k=1:length(c_values)
                if strcmp(vis{k}, 'on')
                    variables_to_save{end+1} = c_values{k};
                end
            end            
        end
    end

    % handle = getSimulinkBlockHandle(blocks.ic.Constant.Path);
    % value = get_param(handle, 'Value');
    % variables_to_save{end+1} = value;
    
    % extract variables from base workspace
    for i=1:length(variables_to_save)
        name = variables_to_save{i};
        idx_dot = strfind(name, '.');

        if idx_dot > 0
            name = name(1:idx_dot-1);
            if strcmp(name, 'active_scenario')
                variables_to_save{i} = '';
                continue
            end
            variables_to_save{i} = name;
        end

       
        
        eval(strcat(name, " = ", "evalin('caller', '", name, "');"));
    end
    

    save(pa(curr_save, 'vars.mat'), variables_to_save{:});
    copyfile(pa(folder_path, strcat(env_name, '.slx')), pa(curr_save, strcat(env_name, "_bckp.slx")));
    copyfile(pa(folder_path, 'config.json'), pa(curr_save, "config.json"));

end