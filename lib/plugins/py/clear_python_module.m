function removed = clear_python_module(module_name)
    removed = evalin('base', strcat("pop(py.sys.modules, '", module_name, "');"));
end

