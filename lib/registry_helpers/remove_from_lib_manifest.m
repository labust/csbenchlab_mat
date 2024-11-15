function remove_from_lib_manifest(name, t, lib_path)
    
    load(fullfile(lib_path, 'manifest.mat'), 'registry', 'version', 'library');
    
    if t == 1
        registry.sys = remove_from_struct(registry.sys, name);
    elseif t == 2
        registry.ctl = remove_from_struct(registry.ctl, name);
    elseif t == 3
        registry.est = remove_from_struct(registry.est, name);
    elseif t == 4
        registry.dist = remove_from_struct(registry.dist, name);
    end

    save(fullfile(lib_path, 'manifest.mat'), 'registry', 'version', 'library');
end



function cell = remove_from_struct(cell, name)
    a = 5;
    indices = cellfun(@(x) ~strcmp(name, x.info.Name), cell);
    cell = cell(indices);
end