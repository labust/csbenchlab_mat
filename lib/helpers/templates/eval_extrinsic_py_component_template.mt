function {{output_args_bracketed}} = {{function_name}}({{input_args}})

    persistent comp_dict
    if isempty(comp_dict)
        comp_dict = dictionary;
    end

    iid = char(iid__);
    if comp_dict.numEntries == 0 || ...
        ~comp_dict.isKey(iid)
        params = get_component_params_from_iid('{{env_name}}', iid__);
        mux = get_controller_mux_struct('{{block_path}}');
        o = PyComponentManager.instantiate_component('{{class_name}}', '{{lib_name}}', {{ctor_args}});
        o.configure({{cfg_args}});
        comp_dict(iid) = o;
    else
        o = comp_dict(iid);
    end
    
    result = o.step({{step_args}});
    {{parse_outputs}}
    comp_dict(iid) = o;
    log = eval_log(o.data);
end

{{eval_log_fn}}
