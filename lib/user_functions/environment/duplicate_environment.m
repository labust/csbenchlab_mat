function newpath = duplicate_environment(env_name, new_name, path)

    if ~is_env_path(env_name)
        [env_path, ~, ~] = fileparts(which(env_name));
    else
        [~, env_name, ~] = fileparts(env_name);
    end

    newpath = fullfile(path,new_name);
    copyfile(env_path, newpath);

    % rename env_name dependent files
    movefile(fullfile(newpath, strcat(env_name, '.cse')), fullfile(newpath, strcat(new_name, '.cse')))
    movefile(fullfile(newpath, env_name), fullfile(newpath, new_name))
    movefile(fullfile(newpath, strcat(env_name, '.slx')), fullfile(newpath, strcat(new_name, '.slx')))
    movefile(fullfile(newpath, strcat(env_name, '_controllers.slx')), ...
        fullfile(newpath, strcat(new_name, '_controllers.slx')));
    movefile(fullfile(newpath, 'autogen', strcat(env_name, '.mat')), ...
        fullfile(newpath, 'autogen', strcat(new_name, '.mat')));
    movefile(fullfile(newpath, 'autogen', strcat(env_name, '_bus_types.sldd')), ...
        fullfile(newpath, 'autogen', strcat(new_name, '_bus_types.sldd')));
    movefile(fullfile(newpath, 'autogen', 'metrics', strcat(env_name, '_eval_metrics.m')), ...
        fullfile(newpath, 'autogen', 'metrics', strcat(new_name, '_eval_metrics.m')));
    movefile(fullfile(newpath, 'parts', strcat(env_name, '_refs.mat')), ...
        fullfile(newpath, 'parts', strcat(new_name, '_refs.mat')));

    metadata = load_env_metadata(newpath);
    metadata.Name = new_name;
    save_env_metadata(newpath, metadata, 0);

end

