function t = block_has_tag(handle, tag)

    tags = get_param(handle, 'Tag');
    if strempty(tags)
        t = 0;
        return
    end
    tags_s = split(tags, ';');
    t = 0;

    starts_with_check = 0;
    if strcmp(tag, '__cs')
        tag = '__cs_comptype';
        starts_with_check = 1;
    end

    for i=1:length(tags_s)
        if isempty(tags_s{i})
            continue
        end
        if starts_with_check
            c = startsWith(tags_s{i}, tag);
        else
            c = strcmp(tags_s{i}, tag);
        end
        if c
            t = 1;
            return
        end
        
    end
    
end


