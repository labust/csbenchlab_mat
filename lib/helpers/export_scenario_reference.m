function export_scenario_reference(env_path, scenario, write_path)
    
    env_refs = load_env_references(env_path, 0);

    idx = cellfun(@(x) strcmp(x.Name, scenario.Reference), env_refs);
    scneario_ref = env_refs{idx};

    if sum(idx) > 1
        warning("More than one scenario reference detected. Saving only the first one");
    end

    save(fullfile(write_path, 'parts', 'scneario_ref.mat'), 'scneario_ref');
end

