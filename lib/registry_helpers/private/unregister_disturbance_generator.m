function unregister_disturbance_generator(name, lib_name)
    

    block_path = strcat(lib_name, '_dist', '/', name);
    delete_block(block_path);
    

end
