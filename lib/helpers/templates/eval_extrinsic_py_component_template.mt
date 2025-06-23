function {{output_args_bracketed}} = {{function_name}}({{input_args}})

    persistent comp_dict
    if isempty(comp_dict)
        comp_dict = dictionary;
    end

    iid = char(iid__);
    if comp_dict.numEntries == 0 || ...
        ~comp_dict.isKey(iid)
        o = PyComponentManager.instantiate_component('{{class_name}}', '{{lib_name}}', {{ctor_args}});
        o.configure({{cfg_args}});
        comp_dict(iid) = o;
    else
        o = comp_dict(iid);
    end
    
    result = o.step({{step_args}});
    {{parse_outputs}}
    data_n = py_parse_component_data(o.data);
    comp_dict(iid) = o;
end

