function on_model_start_impl()
    
    curr_model = gcs;
    mws = get_param(curr_model, 'modelworkspace');
    info = mws.getVariable('env_info');
    ext_value = 0;
    try
        ext_value = mws.getVariable('extrinsic');
    catch
        return
    end
    if ext_value 
        clear_extrinsic_functions(curr_model);
    end
    env_params = load_env_param_struct(curr_model, info, 1);
    assignin('base', matlab.lang.makeValidName(strcat(curr_model, '_params')), env_params);
    trigger_model_callback(curr_model, info, 'on_start');
end

function clear_extrinsic_functions(env_name)
    path = fileparts(which(env_name));

    filelist = dir(fullfile(path, 'autogen'));
    for i=1:length(filelist)
        if ~endsWith(filelist(i).name, '.m')
            continue
        end

        clear(filelist(i).name);
    end
end