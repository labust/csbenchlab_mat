function refresh_csbenchlab()
    clear('get_python_module_from_file');
    terminate(pyenv);
    py.list; % Reload interpreter
end

