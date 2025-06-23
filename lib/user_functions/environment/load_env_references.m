function refs = load_env_references(env_path, check_path)
    if ~exist('check_path', 'var')
        check_path = 1;
    end
    if check_path && ~is_env_path(env_path)
        [env_path, name, ~] = fileparts(which(env_path));
    else
        [~, name, ~] = fileparts(env_path);
    end
    ref_path = fullfile(env_path, 'parts', strcat(name, '_refs.mat'));
    refs = load(ref_path, 'references').references;
    if ~iscell(refs)
        refs = {refs};
    end
end