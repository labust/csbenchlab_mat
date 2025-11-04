function path = get_component_simulink_path(info, comp_type)
    path = fullfile(strcat(info.Lib, '_', comp_type), info.PluginName);
end

