function t = is_valid_component(path, varargin)
    
    if isempty(varargin)
        typ = "";
    else
        typ = varargin{1};
    end

    s = split(path, ':');
    s = s{1};

    if endsWith(s, '.m')
        t = is_valid_m_component(path, typ);
    elseif endsWith(s, '.slx')
        t = is_valid_sim_component(path, typ);
    elseif endsWith(s, '.py')
        t = is_valid_py_component(path, typ);
    else
        t = 0;
    end
end


function r = is_valid_m_component(path, typ)
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

function t = is_valid_sim_component(name, rel_path, typ)
    %TODO
    t = 1;
end

function t = is_valid_py_component(name, typ)
    %TODO
    t = 1;
end

