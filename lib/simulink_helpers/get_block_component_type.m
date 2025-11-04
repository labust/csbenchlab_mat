function t = get_block_component_type(handle)

    tags = get_param(handle, 'Tag');
    if strempty(tags)
        t = 0;
        return
    end
    tags_s = split(tags, ';');
    t = '';
    for i=1:length(tags_s)
        if isempty(tags_s{i})
            continue
        end
        if startsWith(tags_s{i}, '__cs_comptype')
            t_s = split(tags_s{i}, ':');
            if length(t_s) ~= 2
                continue
            end
            t = t_s{2};
        end
    end
end


