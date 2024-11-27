function c = load_env_controllers(env_path)
    if ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    controllers_folder = fullfile(env_path, 'parts', 'controllers');
    
    files = dir(controllers_folder);
    for i=1:length(files)
        f = files(i).name;
        if ~endsWith(f, '.json')
            continue
        end
        if ~exist('c', 'var') 
            c = load_env_controller(env_path, replace(f, '.json', ''));
        else
            c(end+1) = load_env_controller(env_path, replace(f, '.json', ''));
        end
    end
    if ~exist('c', 'var')
        c = [];
    end
end