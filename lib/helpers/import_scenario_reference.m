function import_scenario_reference(env_path, scenario, read_path)
    

    [~, name, ~] = fileparts(env_path);
    env_refs = fullfile(env_path, 'parts', strcat(name, "_refs.mat"));
    c_r = load(env_refs);
    fnames = fieldnames(c_r);

    r = load(fullfile(read_path, 'parts', 'refs.mat'));
    fnames_import = fieldnames(r);


    variables = {};
    for i=1:length(fnames)
        n = fnames{i};
        eval(strcat(n, ' = c_r.("', n, '");'));
        idx = cellfun(@(x) strcmp(x, n), variables);
        if ~any(idx)
            variables{end+1} = n;
        end
    end
    for i=1:length(fnames_import)
        n = fnames_import{i};
        eval(strcat(n, ' = r.("', n, '");'));
        idx = cellfun(@(x) strcmp(x, n), variables);
        if ~any(idx)
            variables{end+1} = n;
        end
    end

    save(env_refs, variables{:});

end

