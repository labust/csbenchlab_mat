function import_scenario_reference(env_path, scenario, read_path)
    
    env_refs = load_env_references(env_path, 0);

    r = load(fullfile(read_path, 'parts', 'scneario_ref.mat')).scneario_ref;
    
    idx = cellfun(@(x) strcmp(x.Name, r.Name), env_refs);

    if any(idx)
        env_refs{idx} = r;
    else
        env_refs{end+1} = r;
    end
    save_env_references(env_path, env_refs);
    
end

