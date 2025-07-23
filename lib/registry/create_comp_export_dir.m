function p = create_comp_export_dir(path)
    
    if ~isfolder(path)
        mkdir(path);
    end
    if ~isfolder(fullfile(path, 'parts'))
        mkdir(fullfile(path, 'parts'));
    end
    if ~isfolder(fullfile(path, 'params'))
        mkdir(fullfile(path, 'params'));
    end
    if ~isfolder(fullfile(path, 'parts', 'controllers'))
        mkdir(fullfile(path, 'parts', 'controllers'));
    end
    if ~isfolder(fullfile(path, 'autogen', 'metrics', 'private'))
        mkdir(fullfile(path, 'autogen', 'metrics', 'private'));
    end
    p = path;
end

