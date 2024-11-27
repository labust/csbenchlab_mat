function register_slx_controller(info, lib_name)
    load_system(info.model_name);
    src = fullfile(info.model_name, info.rel_path);
    splits = split(info.rel_path, '/');
    name = splits{end};
    dest = strcat(lib_name, '_ctl');

    load_system(dest);
    try
        add_block(src, fullfile(dest, name));
        save_system(dest);
    catch
    end
    close_system(info.model_name, 0);
    close_system(dest);
end

    