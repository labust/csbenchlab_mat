function  export_scenario_reference(env_path, scenario, write_path)
    
    [~, name, ~] = fileparts(env_path);

    env_refs = fullfile(env_path, 'parts', strcat(name, "_refs.mat"));

    r = load(env_refs);
    eval(strcat(scenario.Reference, ' = r.("', scenario.Reference, '");'))

    save(fullfile(write_path, 'parts', 'refs.mat'), scenario.Reference);
end

