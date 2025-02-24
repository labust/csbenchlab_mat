function t = is_valid_component(path, varargin)
    
    if isempty(varargin)
        typ = "";
    else
        typ = varargin{1};
    end

    t = is_valid_component_(path, typ);

end


function r = is_valid_component_(path, typ)
    p = get_plugin_info(path);
    if p.T == 0 
        r = 0;
        return
    end
    if strcmp(typ, '')
        r = p.T > 0;
        return
    end
    r = p.T == parse_comp_type(typ);
end
