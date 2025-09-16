function update_env_controllers_with_new_default_params(env_name)
    data = load_env_data(env_name);
    for i=1:length(data.Controllers)
        c = data.Controllers(i);
        info = get_plugin_info_from_lib(c.Type, c.Lib);
        c.Params = make_plugin_parameters(info.Type, info.Name, info.Lib, c.Params);
        save_env_controller(env_name, c, 1);
    end
end