function m = get_python_module(name, lib_name)
   
    info = get_plugin_info_from_lib(name, lib_name);
    comp_path = info.ComponentPath;
    m = get_python_module_from_file(name, comp_path);
end