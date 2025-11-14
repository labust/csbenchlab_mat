function {{output_args_fn}} = {{function_name}}({{input_args}})

    persistent comp_dict
    if isempty(comp_dict)
        comp_dict = dictionary;
    end

    iid = char(iid__);
    if comp_dict.numEntries == 0 || ...
        ~comp_dict.isKey(iid)
        o = load_casadi_component(char(cfg_path));
        o.data = data;
        o.configure();
    else
        o = comp_dict(iid);
    end
    
    [o, u] = o.step(o, y_ref, y, dt);
    {{parse_outputs}}
    comp_dict(iid) = o;
    log = eval_log(o.data);
end

{{eval_log_fn}}
