function type_dict = setup_casadi_component(c_path, type_dict, hws)
    l = libinfo(c_path);

    script_params = get_component_script_parameter_ref(l.ReferenceBlock, {'__plugin_type', '__classname', '__lib_name'});
    plugin_type = script_params{1};
    mux = struct;

    is_controller = is_block_component_of_type(c_path, 'ctl');
    if is_controller
        try
            mux = get_controller_mux_struct(c_path);
        catch
            mux = evalin('base', 'mux');
        end
    end

    name =  make_class_name(c_path);
    if length(name) > namelengthmax
        error(strcat("Name '", name, "' is larger than max. Consider renaming components."));
    end
    params = get_component_params_from_block(c_path);

    if strcmp(plugin_type, 'py')
        [path, type_dict] = setup_casadi_py(c_path, script_params{2}, script_params{3}, ...
            params, mux, hws, type_dict);
    elseif strcmp(plugin_type, 'mat')
        setup_casadi_mat();
    end
    set_mask_values(c_path, 'cfg_path', mat2str(uint8(path)));
end


function [tmp_folder, type_dict] = setup_casadi_py(c_path, class_name, lib_name, params, mux, hws, type_dict)
    m = get_python_module(class_name, lib_name, 1);
    instance = m.(class_name)('Params', params, 'Mux', mux);
    if ~py.hasattr(instance, 'casadi_step_fn')
        error(strcat("Casadi plugin '", class_name, "' does not " + ...
            "implement 'casadi_step_fn' function."));
    end


    tmp_folder = fullfile(tempdir, strcat('csb_casadi_', class_name, ...
        '_', lib_name));

    if ~exist(tmp_folder, 'dir')
        mkdir(tmp_folder);
    end

    save_casadi_component(tmp_folder, instance);
    m = PyComponentManager;
    data = m.create_component_data_model(class_name, lib_name, params, mux);
    log_desc = m.get_component_log_description(class_name, lib_name);
    name =  make_class_name(c_path);

    hws.assignin(strcat(name, '_data'), data);

    type_dict = m.generate_busses(name, struct, data, ...
        log_desc, {}, type_dict);

end

function setup_casadi_mat(class_name, lib_name, params, mux)

end