function info = get_slx_plugin_info(model_name, rel_path)
    info = struct;
    info.T = 0;
    
    n_split = split(rel_path, '/');

    info.Name = n_split{end};
    load_system(model_name);
    h = getSimulinkBlockHandle(fullfile(model_name, rel_path));
    if h == -1
        close_system(model_name, 0);
        error(strcat("Model block '", model_name, ":", rel_path, "' does not exist"));
    end
    inputs = get(find_system(h, 'FindAll', 'On', 'LookUnderMasks', 'on', 'SearchDepth', 1, 'BlockType', 'Inport' ), 'Name');
    outputs = get(find_system(h, 'FindAll', 'On', 'LookUnderMasks', 'on', 'SearchDepth', 1, 'BlockType', 'Outport' ), 'Name');
    if is_sys(inputs, outputs)
        info.T = 1;
    elseif is_ctl(inputs, outputs)
        info.T = 2;
    elseif is_est(inputs, outputs)
        info.T = 3;
    elseif is_dist(inputs, outputs)
        info.T = 4;
    end
    info.model_name = model_name;
    info.rel_path = rel_path;
    close_system(model_name, 0);
end


function t = is_sys(inputs, outputs)
    t = 0;
    if length(inputs) < 4 || length(outputs) < 1
        return
    end
    t = strcmp(inputs{1}, 'u') && strcmp(inputs{2}, 't') ...
        && strcmp(inputs{3}, 'dt') && strcmp(inputs{4}, 'ic') ...
        && strcmp(outputs{1}, 'y');
end


function t = is_ctl(inputs, outputs)
    t = 0;
    if length(inputs) < 3 || length(outputs) < 2
        return
    end
    t = strcmp(inputs{1}, 'y_ref') && strcmp(inputs{2}, 'y') ...
        && strcmp(inputs{3}, 'dt') && strcmp(outputs{1}, 'u') ...
        && strcmp(outputs{2}, 'log');
end
function t = is_est(inputs, outputs)
    t = 1;
end
function t = is_dist(inputs, outputs)
    t = 1;
end