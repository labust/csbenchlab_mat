function h = encode_plugin_id(name, lib_name)
    h = convertStringsToChars(strcat(name, ":", lib_name));
end

