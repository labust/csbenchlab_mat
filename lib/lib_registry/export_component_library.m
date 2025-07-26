function export_component_library(lib_name)
    reg = CSPath.get_app_registry_path();
    path = fullfile(reg, lib_name);
    

    copyfile(path, fullfile('export', lib_name));
    rmdir(fullfile('export', lib_name, 'autogen'), "s");
    mkdir(fullfile('export', lib_name, 'autogen'));
end

