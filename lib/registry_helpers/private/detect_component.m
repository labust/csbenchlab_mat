function registry = detect_component(path, registry)

    splits = split(path, ":");
    prefix_path = splits(1);
    if length(splits) > 1
        sufix_path = splits(2);
    else
        sufix_path = "";
    end

    if endsWith(prefix_path, '.m')
        p = get_plugin_info(prefix_path);
        registry = add_component_to_registry(registry, p);
    elseif endsWith(prefix_path, '.py')
        p = get_plugin_info(prefix_path);
        registry = add_component_to_registry(registry, p);
    elseif endsWith(prefix_path, '.slx')
        [~, sim_lib_name, ~] = fileparts(prefix_path);
        h_first = getSimulinkBlockHandle(sim_lib_name);
        if h_first == -1
            h = load_and_unlock_system(sim_lib_name);
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
                    if is_valid_component(full_path)
                        p = get_plugin_info(full_path);
                        registry = add_component_to_registry(registry, p);
                    end
                    break;
                end
            else
                if is_valid_component(full_path)
                    p = get_plugin_info(full_path);
                    registry = add_component_to_registry(registry, p);
                end
            end
        end
    
        if h_first == -1
            close_system(sim_lib_name);
        end
    end
end

