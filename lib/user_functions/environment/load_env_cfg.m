function cfg = load_env_cfg(env_path)
    
    cfg_file = fullfile(env_path, 'config.json');
    cfg = readstruct(cfg_file);
end

