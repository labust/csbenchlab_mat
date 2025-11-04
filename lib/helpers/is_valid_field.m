function t = is_valid_field(s, name)
    
    if ~isfield(s, name)
        t = 0;
        return
    end
    v = s.(name);
    if isa(v, 'string')
        t = v ~= "";
    elseif isa(v, 'struct')
        t = ~isempty(fieldnames(v));
    else
        t = ~isempty(s.(name));
    end
    
end