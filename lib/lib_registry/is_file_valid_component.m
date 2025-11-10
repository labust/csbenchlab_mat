function t = is_file_valid_component(path, varargin)
    
    if isempty(varargin)
        typ = "";
    else
        typ = varargin{1};
    end

    t = is_valid_component_(path, typ);

end


function r = is_valid_component_(path, typ)
    p = get_plugin_info_from_file(path);
    if strcmp(p.T, '')
        r = 0;
        return
    end
    if strcmp(typ, '')
        r = 1;
        return
    end
    r = strcmp(p.T, typ);
end
