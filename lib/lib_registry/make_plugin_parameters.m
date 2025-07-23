function params = make_plugin_parameters(plugin_type, plugin_name, lib_name)

    m = ComponentManager.get(plugin_type);  
    params = m.make_component_params(plugin_name, lib_name);
end
