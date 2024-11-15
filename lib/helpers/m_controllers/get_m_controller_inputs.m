function inputs = get_m_controller_inputs(class_name)
    inputs = {};
    try
        eval(strcat("inputs = ", class_name, ".io_description;"));
    catch ME
    end
end
