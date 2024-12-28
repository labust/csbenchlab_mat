function t = model_has_tag(handle, tag)

    tags = get_param(handle, 'Tag');
    if strempty(tags)
        t = 0;
        return
    end
    tags_s = split(tags, ';');
    t = 0;
    for i=1:length(tags_s)
        if isempty(tags_s{i})
            continue
        end
        if strcmp(tags_s{i}, tag)
            t = 1;
            return
        end
        

        if startsWith(tag, '__cs')
            t_s = split(tags_s{i}, '_');
            if length(t_s) ~= 5
                continue
            end
            if strcmp(tag, '__cs_sys') && strcmp(t_s{5}, 'sys') ...
                    || strcmp(tag, '__cs_ctl') && strcmp(t_s{5}, 'ctl') ...
                    || strcmp(tag, '__cs_est') && strcmp(t_s{5}, 'est') ...
                    || strcmp(tag, '__cs_dist') && strcmp(t_s{5}, 'dist') ...
                    || strcmp(tag, '__cs_m') && strcmp(t_s{4}, 'm') ...
                    || strcmp(tag, '__cs_slx') && strcmp(t_s{4}, 'slx') ...
                    || strcmp(tag, '__cs_py') && strcmp(t_s{4}, 'py') ...
                    || strcmp(tag, '__cs') && strcmp(t_s{3}, 'cs')
                t = 1;
                return
            end
            
        end
        
    end
    
end


