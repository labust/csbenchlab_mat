function m = get_python_module(name, lib_name, ignore_cache)
    if ~exist('ignore_cache', 'var')
        ignore_cache = 0;
    end
    info = get_plugin_info_from_lib(name, lib_name);
    comp_path = info.ComponentPath;
    m = get_python_module_from_file(name, comp_path, ignore_cache);
end