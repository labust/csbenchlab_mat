function save_env_cfg(env_path, cfg)
    cfg_file = fullfile(env_path, 'config.json');
    writestruct(cfg, cfg_file, 'FileType','json');

end

