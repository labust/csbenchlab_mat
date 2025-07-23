function save_params_struct(env_path, obj)
    
    eval(strcat(obj.ParamsStructName, '= options.Params'));
    file = fullfile(env_path, 'params', obj.Id);
    save(file, obj.ParamsStructName);
end

