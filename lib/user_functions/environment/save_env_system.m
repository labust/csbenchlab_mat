function save_env_system(env_path, system)
    if ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, 'parts', 'system.json');
    writestruct(system, f, 'FileType', 'json');    
end