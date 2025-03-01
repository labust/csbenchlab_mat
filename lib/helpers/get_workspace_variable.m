function value = get_workspace_variable(name)
    value = evalin('base', name);
end

