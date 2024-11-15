function evaluate_mask_parameters_on_load(params, block_path)
    
    if ~isfield(params, 'eval__')
        return
    end

    eval_params = params.eval__;

    fn = fieldnames(eval_params);
    mo = get_param(block_path, 'MaskObject');
    h = get_param(block_path, 'Handle');

    for i=1:length(fn)
        name = fn{i};
        value = eval_params.(name);

        if isa(value, 'EvalParam')            
            evaluated = eval(strcat(value.EvalFn, "(block_path, value.EvalArgs{:});"));

            if ~any(arrayfun(@(x) strcmp(x.Name, fn{i}), mo.Parameters))
                error(strcat("Cannot set mask parameter '", name, "'. Parameter ", ...
                    "does not exist on object '", block_path, "'"));

                mo.addParameter('Name', fn{i}, 'Value', evaluated, 'Visible', 'off');
            else
                set_mask_values(h, fn{i}, evaluated);
            end
        end
    end
end

