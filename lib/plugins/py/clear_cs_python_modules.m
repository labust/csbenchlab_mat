function removed = clear_cs_python_modules()

    modules = py.list(py.sys.modules);
    for i=1:length(modules)
        name = string(modules(i));
        if startsWith(name, 'csbenchlab')
            removed = evalin('base', strcat("pop(py.sys.modules, '", name, "');"));
        end
    end
end

