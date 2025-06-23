function s = load_env_scenarios(env_path, check_path)
    if ~exist('check_path', 'var')
        check_path = 1;
    end
    if check_path && ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    f = fullfile(env_path, 'parts', 'scenarios.json');
    if exist(f, "file")
        s = readstruct(f);
    else
        s = [];
    end

    if isempty(s)
        return
    end

    for i=1:length(s)
        s(i) = load_component_params(s(i), env_path);
    end

end
