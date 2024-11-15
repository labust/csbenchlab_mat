function data_name = gen_data_value(block_path, block_name)
    pa = @BlockHelpers.path_append;
    name = make_class_name(pa(block_path, block_name));
    data_name = strcat(name, '_data');

end

