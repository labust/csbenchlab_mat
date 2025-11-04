function params = get_component_params_from_iid(env_name, iid)
    hws = get_param(env_name, 'modelworkspace');
    map = hws.getVariable('id_to_params_path_map');
    params = evalin('base', map(char(iid)));
end
