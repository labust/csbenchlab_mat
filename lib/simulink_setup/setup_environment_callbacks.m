function setup_environment_callbacks(model_name, env_path)
    
    mws = get_param(model_name, 'modelworkspace');
    callbacks = eval_environment_callbacks(env_path);
    mws.assignin('callbacks', callbacks);
    
end