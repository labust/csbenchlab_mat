function context_path = get_component_context_path_from_iid(iid)
    iid_str = char(iid);
    [~, params] = get_env_param_struct();
    context_path = params.ComponentContext(iid_str);
end
