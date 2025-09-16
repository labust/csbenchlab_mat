function setup_simulink_references(env_name, info, blocks, scenarios, active_scenario)
    folder_path = fileparts(which(env_name));
    sig_editor_h = getSimulinkBlockHandle(fullfile(blocks.refgen.Path, 'Reference'));

    refs = load_env_references(env_name);
    path = generate_dataset_references(env_name, folder_path, info, blocks, refs, scenarios);

    set_param(sig_editor_h, 'FileName', path);
    selector_name = fullfile(blocks.refgen.Path, 'Reference');

    set_param(selector_name, 'ActiveScenario', get_ref_name(active_scenario.Name));
end


function path = generate_dataset_references(env_name, env_path, info, blocks, refs, scenarios)
    save_names = {};
    for i=1:length(scenarios)
        scenario = scenarios(i);
        idx = cellfun(@(x) isa(x, 'Simulink.SimulationData.Dataset') && ...
            strcmp(x.getElement(1).Name, scenario.Reference)...
            || strcmp(x.Name, scenario.Reference), refs);
        ref = refs{idx};

        if isa(ref, 'Simulink.SimulationData.Dataset')
            ds = ref;
        else
            ds = Simulink.SimulationData.Dataset;
            if isa(ref.Data, 'function_handle')           
                data = ref.Data(scenario.Params.RefParams, info.Metadata.Ts, blocks.systems.dims);
            else
                data = ref.Data;
            end
            if ~isa(data, 'timeseries')
                error(strcat("Error generating reference for scenario ", scenario.Name, ...
                 "'. Data is not timeseries."));
            end
            ds = ds.addElement(data);
        end
        fixed_name = get_ref_name(scenario.Name);
        eval(strcat(fixed_name, ' = ds;'));
        save_names{end+1} = fixed_name;
    end
    path = fullfile(env_path, 'autogen', strcat(env_name, '_dataset_ref.mat'));
    save(path, save_names{:});
end

function n = get_ref_name(n)
    n = replace(n, ' ', '_');
end