function map = set_component_params_map(env_name, comp, map)
    
    save = 0;
    if ~exist("map", 'var')
        hws = get_param(env_name, 'modelworkspace');
        map = hws.getVariable('id_to_params_path_map');
        save = 1;
    end

    params_path = get_component_params_from_env(env_name, comp);
    map(comp.Id) = params_path;
    if save
        hws.assignin('id_to_params_path_map', map);
    end
end

