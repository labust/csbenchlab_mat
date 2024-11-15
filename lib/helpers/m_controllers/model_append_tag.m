function model_append_tag(handle, tag)

    tags = get_param(handle, 'Tag');
    tags_s = split(tags, ';');

    for i=1:length(tags_s)
        if strcmp(tag, tags_s{i})
           return 
        end
    end
    set_param(handle, 'Tag', strcat(tags, tag, ';'));
end

