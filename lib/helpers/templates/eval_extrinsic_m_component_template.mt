function {{output_args_fn}} = {{function_name}}({{input_args}})

    persistent comp_dict
    if isempty(comp_dict)
        comp_dict = dictionary;
    end

    iid = char(iid__);
    if comp_dict.numEntries == 0 || ...
        ~comp_dict.isKey(iid)
        o = {{class_name}}({{ctor_args}});
        o = o.configure({{cfg_args}});
        comp_dict(iid) = o;
    else
        o = comp_dict(iid);
    end
    
    [o, {{comp_outputs}}] = o.step({{step_args}});
    comp_dict(iid) = o;
    log = eval_log(o.data);
end

{{eval_log_fn}}

