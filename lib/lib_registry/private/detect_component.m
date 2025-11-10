function registry = detect_component(path, registry)

    splits = split(path, ":");
    prefix_path = splits(1);
    if length(splits) > 1
        sufix_path = splits(2);
    else
        sufix_path = "";
    end

    typ = ComponentRegister.get_plugin_type_from_file(path);

    % simple if not slx
    if ~is_component_type(typ, 'slx')
        p = get_plugin_info_from_file(prefix_path);
        if isempty(p.T)
            warning(strcat("Component on path '", path, "' is not valid and is " + ...
                "not registered. Skipping..."));
            return
        end
        registry = add_component_to_registry(registry, p);
    else
        [~, sim_lib_name, ~] = fileparts(prefix_path);
        h_first = getSimulinkBlockHandle(sim_lib_name);
        if h_first == -1
            try
                h = load_and_unlock_system(sim_lib_name);
            catch
                warning(strcat("Simulink model with name '", sim_lib_name, ...
                    "' is not on path. Skipping..." ));
                return
            end
        end

        objects = find_system(h, 'SearchDepth', 1);
        
        % sim_name = get_param(objects(objects == h), 'Name');
        for k=1:length(objects)
            if objects(k) == h
                continue
            end
            full_path = prefix_path + ":" + get_param(objects(k), 'Name');
            
            if ~strempty(sufix_path)
                if strcmp(full_path, strtrim(path))
                    if is_file_valid_component(full_path)
                        p = get_plugin_info_from_file(full_path);
                        registry = add_component_to_registry(registry, p);
                    end
                    break;
                end
            else
                if is_file_valid_component(full_path)
                    p = get_plugin_info_from_file(full_path);
                    registry = add_component_to_registry(registry, p);
                end
            end
        end
    
        if h_first == -1
            close_system(sim_lib_name);
        end
    end
end

