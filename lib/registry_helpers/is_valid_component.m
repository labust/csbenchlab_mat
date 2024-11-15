function t = is_valid_component(path, varargin)
    
    if isempty(varargin)
        typ = "";
    else
        typ = varargin{1};
    end

    [filepath, name, ext] = fileparts(path);

    if strcmp(ext, '.m')
        t = is_valid_m_component(name, typ);
    elseif strcmp(ext, '.slx')
        t = is_valid_sim_component(name, typ);
    elseif strcmp(ext, '.py')
        t = is_valid_py_component(name, typ);
    else
        t = 0;
        return
    end
end


function r = is_valid_m_component(name, typ)
    [t, ~] = get_plugin_type(name);
    if t == 0 
        r = 0;
        return
    end
    if strcmp(typ, '')
        r = t > 0;
        return
    end
    r = t == parse_comp_type(typ);
end

function t = is_valid_sim_component()
    %TODO
    t = 1;
end

function t = is_valid_py_component()
    %TODO
    t = 1;
end

