function p_path = get_parent_controller(path)
    pa = @BlockHelpers.path_append;
    splits = split(path, '/');

    curr_path = splits{1};
    p_path = path;
    for i=2:length(splits)
        if model_has_tag(curr_path, '__cs_ctl')
            p_path = curr_path;
            return
        end
        curr_path = pa(curr_path, splits{i});
    end


end

