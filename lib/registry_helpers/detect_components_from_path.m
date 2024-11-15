
function registry = detect_components_from_path(path, registry)
    
    [~, atrs] = fileattrib(path);
    filelist = dir(fullfile(atrs.Name, '*.m')); 


    for j = 1:length(filelist)
        p = detect_component(fullfile(path, filelist(j).name));
        if p.t == 1
            registry.sys{end+1} = p;
        elseif p.t == 2
            registry.ctl{end+1} = p;
        elseif p.t == 3
            registry.est{end+1} = p;
        elseif p.t == 4
            registry.dist{end+1} = p;
        end
    end

end