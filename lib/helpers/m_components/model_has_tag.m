function t = model_has_tag(handle, tag)

    tags = get_param(handle, 'Tag');
    tags_s = split(tags, ';');
    
    t = 0;
    for i=1:length(tags_s)
        if strcmp(tag, tags_s{i})
           t = 1; 
           return
        end
    end
end

