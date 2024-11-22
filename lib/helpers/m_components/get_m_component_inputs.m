function inputs = get_m_component_inputs(class_name)
    inputs = {};
    try
        eval(strcat("inputs = ", class_name, ".input_description;"));
    catch ME
    end
end
