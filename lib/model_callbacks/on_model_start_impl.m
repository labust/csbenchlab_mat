function on_model_start_impl()
    
    curr_model = gcs;
    mws = get_param(curr_model, 'modelworkspace');
    ext_value = 0;
    try
        ext_value = mws.getVariable('extrinsic');
    catch
        return
    end
    if ext_value 
        clear_extrinsic_functions(curr_model);

    end
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