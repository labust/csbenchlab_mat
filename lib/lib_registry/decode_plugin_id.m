function [name, lib_name] = decode_plugin_id(id)
    str = char(id);
    idx = find(str == ':', 1, 'first');
    name = str(1:idx(1)-1);
    lib_name = str(idx(1)+1:length(str));
end

