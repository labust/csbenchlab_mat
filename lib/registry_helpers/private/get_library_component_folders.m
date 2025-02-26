function folders = get_library_component_folders(path)
    
    ps = plugin_sufix();
    cs = component_type_sufix();
    rel_paths = fullfile("src", reshape(repmat(ps,length(cs),1),[],1), repmat(cs(:),length(ps),1));
    as_cell = num2cell(fullfile(path, rel_paths), length(rel_paths));
    folders = [
        {string(path)}, ...
        as_cell(:)'
    ];
end


function s = plugin_sufix()
    s = [
        "m", "py"
        ];
end


function s = component_type_sufix()
    s = [
        "ctl", "dist", "est", "sys"
        ];
end

