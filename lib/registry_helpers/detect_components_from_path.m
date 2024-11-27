
function registry = detect_components_from_path(path, registry)

    if exist('registry', 'var')
        registry.ctl = {};
        registry.sys = {};
        registry.est = {};
        registry.dist = {};
    end
    
    [~, atrs] = fileattrib(path);
    filelist = dir(fullfile(atrs.Name, '*.m')); 


    for j = 1:length(filelist)
        p = get_plugin_info(fullfile(path, filelist(j).name));
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

end