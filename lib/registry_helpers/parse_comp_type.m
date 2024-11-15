function t = parse_comp_type(typ)
    if strcmp(typ, 'sys')
        t = 1;
    elseif strcmp(typ, 'ctl')
        t = 2;
    elseif strcmp(typ, 'est')
        t = 3;
    elseif strcmp(typ, 'dist')
        t = 4;
    else
        t = 0;
    end
end