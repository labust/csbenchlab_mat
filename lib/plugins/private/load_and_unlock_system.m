function h = load_and_unlock_system(name)
    h = load_system(name);
    set_param(h, 'Lock', 'off');
end

