function m = get_python_module_from_pid(pid)
    [name, lib_name] = decode_plugin_id(pid);
    m = get_python_module(name, lib_name);
end