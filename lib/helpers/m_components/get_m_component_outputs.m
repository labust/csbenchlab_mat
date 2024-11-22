function inputs = get_m_component_outputs(class_name)
    inputs = {};
    try
        eval(strcat("outputs = ", class_name, ".output_description;"));
    catch ME
    end
end
