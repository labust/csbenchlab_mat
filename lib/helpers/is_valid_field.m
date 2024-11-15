function t = is_valid_field(s, name)
    
    if ~isfield(s, name)
        t = 0;
        return
    end
    if isa(s.(name), 'string')
        t = s.(name) ~= "";
    else
        t = ~isempty(s.(name));
    end
end