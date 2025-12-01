function paths = get_env_folder_paths(env_path, env_name)
    function rf = recurse_folders(path)
        rf = dir(fullfile(path, '**'));
        rf = rf([rf.isdir] & ~strcmp({rf.name}, '.')  & ~strcmp({rf.name}, '..'));
        if isempty(rf)
            rf = string(path);
            return
        end
        rf = [string(path),
            arrayfun(@(x) string(fullfile(x.folder, x.name)), rf)]; 
    end
    env_paths = recurse_folders(fullfile(env_path, env_name));
    paths = [
        {env_path}, ...
        {fullfile(env_path, 'autogen')}, ...
        env_paths(:)', ...
        {fullfile(env_path, 'parts')}, ...
        ];
end
