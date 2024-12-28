
function registry = detect_components_from_path(path, registry)

    if ~exist('registry', 'var')
        registry.ctl = {};
        registry.sys = {};
        registry.est = {};
        registry.dist = {};
    end
    
    [~, atrs] = fileattrib(path);
    filelist = dir(fullfile(atrs.Name, '*.m')); 

    for j = 1:length(filelist)
        p = get_plugin_info(fullfile(path, filelist(j).name));
        registry = add_component_to_registry(registry, p);
    end

    filelist = dir(fullfile(atrs.Name, '*.slx'));
    for j=1:length(filelist)
        slx_path = fullfile(path, filelist(j).name);
        
        h = load_system(slx_path);
        objects = find_system(h, 'SearchDepth', 1);
        
        % sim_name = get_param(objects(objects == h), 'Name');
        for k=1:length(objects)
            if objects(k) == h
                continue
            end
            full_path = slx_path + ":" + get_param(objects(k), 'Name');
            if is_valid_component(full_path)
                p = get_plugin_info(full_path);
                registry = add_component_to_registry(registry, p);
            end
        end
        close_system(slx_path);
    end

    filelist = dir(fullfile(atrs.Name, '*.py'));
    for j=1:length(filelist)
        % TODO
        p = get_plugin_info(fullfile(path, filelist(j).name));
        registry = add_component_to_registry(registry, p);
    end


end


function registry = add_component_to_registry(registry, p)
    if p.T == 1
        registry.sys{end+1} = p;
    elseif p.T == 2
        registry.ctl{end+1} = p;
    elseif p.T == 3
        registry.est{end+1} = p;
    elseif p.T == 4
        registry.dist{end+1} = p;
    end
end