function unregister_controller(name, lib_name)
    n = strcat(lib_name, '_ctl');
    block_path = fullfile(n, name);
    load_system(n);
    try
        delete_block(block_path);
        save_system(n);
    catch
    end
    close_system(n);
    

end
