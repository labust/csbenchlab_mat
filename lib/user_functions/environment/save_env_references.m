function save_env_references(env_path, references)
    if ~is_env_path(env_path)
        [env_path, ~, ~] = fileparts(which(env_path));
    end
    validate_references(references);
    [~, name, ~] = fileparts(env_path);
    ref_path = fullfile(env_path, 'autogen', strcat(name, '_refs.mat'));
    save(ref_path, 'references');
end