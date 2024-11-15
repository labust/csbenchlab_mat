function n = make_class_name(name)

    n = strrep(name, '/', '_');
    n = strrep(n, ' ', '_');

end

