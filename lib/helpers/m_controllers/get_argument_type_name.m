function n = get_argument_type_name(path, arg_name)
    name = make_class_name(path); 
    n = strcat(name, '_', arg_name, "_T");
end

