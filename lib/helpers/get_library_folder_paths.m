function paths = get_library_folder_paths(lib_path, name)
    
    function rf = recurse_folders(path)
        rf = dir(fullfile(path, '**'));
        rf = rf([rf.isdir] & ~strcmp({rf.name}, '.')  & ~strcmp({rf.name}, '..'));
        if isempty(rf)
            rf = string(path);
            return
        end
        rf = [string(path); ...
            arrayfun(@(x) string(fullfile(x.folder, x.name)), rf)]; 
    end
    lib_paths = recurse_folders(fullfile(lib_path, name));
    src_paths = recurse_folders(fullfile(lib_path, 'src'));
    paths = [
        {lib_path}, ...
        {fullfile(lib_path, 'autogen')}, ...
        lib_paths(:)', ...
        src_paths(:)' ...
        ];
end