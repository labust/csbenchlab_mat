function export_component_library(lib_name)
    
    path = get_library_path(lib_name);
    
   
    copyfile(path, fullfile('export', lib_name));
    rmdir(fullfile('export', lib_name, 'autogen'), "s");
    mkdir(fullfile('export', lib_name, 'autogen'));
end

