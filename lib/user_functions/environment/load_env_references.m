function refs = load_env_references(env_path)
    if is_env_path(env_path)
        [~, name, ~] = fileparts(env_path);
    else
        [env_path, name, ~] = fileparts(which(env_path));
    end
    ref_path = fullfile(env_path, 'autogen', strcat(name, '_refs.mat'));
    refs = load(ref_path);
    names = fieldnames(refs);
    refs = refs.(names{1});
end