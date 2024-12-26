function s = load_env_system(env_path, check_path)
    if ~exist('check_path', 'var')
        check_path = 1;
    end
    if check_path &&~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, 'parts', 'system.json');
    if exist(f, "file")
        s = readstruct(f);
    else
        s = struct([]);
    end
    
    if isempty(s)
        return
    end
    s = load_component_params(s, env_path);
end