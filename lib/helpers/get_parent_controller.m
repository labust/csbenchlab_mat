function p_path = get_parent_controller(path)
    pa = @BlockHelpers.path_append;
    splits = split(path, '/');

    curr_path = splits{1};
    p_path = path;
    for i=2:length(splits)
        if is_block_component_of_type(curr_path, 'ctl')
            p_path = curr_path;
            return
        end
        curr_path = pa(curr_path, splits{i});
    end


end

