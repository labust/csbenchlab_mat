function setup_simulink_references(env_name, info, blocks, active_scenario)
    folder_path = fileparts(which(env_name));
    sig_editor_h = getSimulinkBlockHandle(fullfile(blocks.refgen.Path, 'Reference'));

    refs = load_env_references(env_name);
    path = generate_dataset_references(env_name, folder_path, info, blocks, refs, active_scenario);

    set_param(sig_editor_h, 'FileName', path);
    selector_name = fullfile(blocks.refgen.Path, 'Reference');
    set_param(selector_name, 'ActiveScenario', active_scenario.Reference);
end


function path = generate_dataset_references(env_name, env_path, info, blocks, refs, active_scenario)

    idx = cellfun(@(x) strcmp(x.Name, active_scenario.Reference), refs);
    ref = refs{idx};
    ds = Simulink.SimulationData.Dataset;
    if isa(ref.Data, 'function_handle')           
        data = ref.Data(active_scenario.Params.RefParams, info.Metadata.Ts, blocks.systems.dims);
    else
        data = ref.Data;
    end
    if ~isa(data, 'timeseries')
        error(strcat("Error generating reference for scenario ", active_scenario.Name, ...
         "'. Data is not timeseries."));
    end
    ds = ds.addElement(data);
    eval(strcat(ref.Name, ' = ds;'));
    path = fullfile(env_path, 'autogen', strcat(env_name, '_dataset_ref.mat'));
    save(path, ref.Name);
end