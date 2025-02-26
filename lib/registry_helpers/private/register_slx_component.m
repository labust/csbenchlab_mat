function register_slx_component(info, typ, lib_name, tags, size)
    load_system(info.model_name);
    src = fullfile(info.model_name, info.rel_path);
    splits = split(info.rel_path, '/');
    name = splits{end};
    dest = strcat(lib_name, '_', typ);
    load_system(dest);
    
    GRID_LEN = 4;
    count = length(find_system(dest, 'SearchDepth', 1)) - 1;
    idx_j = floor(count / GRID_LEN) + 1;
    idx_i = mod(count, GRID_LEN) + 1;
    dl = 200;
    if ~exist("size", 'var')
        size = [80, 50];
    end
    position = [idx_i * dl, idx_j * dl, idx_i * dl + size(1), idx_j * dl + size(2)]';

    load_and_unlock_system(dest);
    
    % delete block if exists

    dest_path = fullfile(dest, name);
    handle = getSimulinkBlockHandle(dest_path);
    if handle ~= -1
        delete_block(dest_path);    
    end
    try
        block = add_block(src, dest_path);
        set_param(block, 'Position', position);
        for i=1:length(tags)
            model_append_tag(block, tags{i});
        end

        save_system(dest);
    catch
    end
    close_system(info.model_name, 0);
    close_system(dest);
end

    