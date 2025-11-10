function export_component_library(lib_name, dest_path)
    
    path = get_library_path(lib_name);
    
   
    copyfile(path, fullfile(dest_path, lib_name));
    rmdir(fullfile(dest_path, lib_name, 'autogen'), "s");
end

