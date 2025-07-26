function {{output_args_fn}} = fcn({{input_args}}, pid__, iid__, extrinsic)
    coder.extrinsic('fcn_{{function_name}}_ext');
    if extrinsic
{{extrinsic_init}};
        {{output_args_fn}} = fcn_{{function_name}}_ext({{input_args}}, pid__, iid__);
    else
        {{output_args_fn}} = fcn_{{function_name}}({{input_args}}, pid__, iid__);
    end 
end

 
function {{output_args_fn}} = fcn_{{function_name}}({{input_args}}, pid__, iid__)
    persistent obj
    if isempty(obj)
        obj = {{class_name}}({{ctor_args}}, 'pid', pid__, 'iid', iid__);
        obj = obj.configure({{cfg_args}});
    end
    [obj, {{output_args}}] = obj.step({{step_args}});
    log = eval_log(obj.data);
end

function log = eval_log(data)
    {{logging_define}}
end
