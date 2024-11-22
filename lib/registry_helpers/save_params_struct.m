function save_params_struct(env_path, options)
    
    eval(strcat(options.ParamsStructName, '= options.Params'));
    file = fullfile(env_path, 'params', options.Id);
    save(file, options.ParamsStructName);
end

