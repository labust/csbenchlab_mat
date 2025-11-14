function save_casadi_component(comp_path, comp_instance)
    
    % if ~py.hasattr(comp_instance, 'casadi_configure_fn')
    %     error("Casadi component has no 'casadi_configure_fn' function");
    % end
    % if ~py.hasattr(comp_instance, 'casadi_data_update_fn')
    %     error("Casadi component has no 'casadi_data_update_fn' function");
    % end
    if ~py.hasattr(comp_instance, 'casadi_step_fn')
        error("Casadi component has no 'casadi_step_fn' function");
    end
    
    functions = comp_instance.step_fns;
    l = length(functions);
    for i=1:l
        functions{i}.save(fullfile(comp_path, strcat('step_', num2str(i), '.casadi')));
    end
end

