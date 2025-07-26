function csbenchlab_hyperparam_optim(env_name)
    
    env_path = env_name;
    if ~is_env_path(env_name)
        env_path = fileparts(which(env_name));
    end
    
    dest = fullfile(env_path, 'hyperparam_optim', 'HyperparameterOptimization');
    if ~exist(fullfile(env_path, 'hyperparam_optim'), 'dir')
        mkdir(fullfile(env_path, 'hyperparam_optim'));
        root = CSPath.get_app_root_path();
        mkdir(dest);
        copyfile(fullfile(root, 'HyperparameterOptimization'), dest);
    end
    cd(dest);
    experimentManager;

end

