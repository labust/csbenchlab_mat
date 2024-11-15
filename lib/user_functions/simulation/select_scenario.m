function  select_scenario(env_name, scenario)
    pa = @BlockHelpers.path_append;

     % if no config, this is not an environment
    if ~exist(pa(env_name, 'config.json'), 'file')
        return
    end


    
    
    ref_gen_name = pa(env_name, 'RefGenerator');
    handle = get_param(ref_gen_name, 'Handle');

    mo = get_param(handle, 'MaskObject');


    if ~exist("scenario", "var")
        scenarios = load_scenarios(env_name);
        scenario = scenarios(1).Name;
    end

    if any(strcmp(mo.Parameters.TypeOptions, scenario))
        mo.Parameters.Value = scenario;
        on_reference_select();
    else
        error(strcat("Scenario '", scenario, "' does not exist in the environment '", env_name, "'"));
    end

end

