classdef MatComponentManager  < ComponentManager
    

    methods (Static)
        function data = create_component_data_model(class_name, ~, params, mux)
    
            add_mux_arg_str = "";
            if isempty(mux)
                add_mux_arg_str = ", mux";
            end
            data = eval(strcat(class_name, '.create_data_model(params', add_mux_arg_str, ');'));
        end

        function params = get_component_params(class_name, ~)
            params = {};
            try
                eval(strcat("params = ", class_name, ".param_description;"));
            catch ME
            end
        end


        function logs = get_component_log_description(class_name, ~)
            logs = {};
            try
                eval(strcat("logs = ", class_name, ".log_description;"));
            catch ME
            end
        end

        function inputs = get_component_inputs(class_name, ~)
            inputs = {};
            try
                eval(strcat("inputs = ", class_name, ".input_description;"));
            catch ME
            end
        end

        function inputs = get_component_outputs(class_name, ~)
            inputs = {};
            try
                eval(strcat("outputs = ", class_name, ".output_description;"));
            catch ME
            end
        end

        function resolved = make_component_params(class_name, param_values)
    
            if ~exist('param_values', 'var')
                param_values = struct;
            end
            desc = eval(strcat(class_name, '.param_description'));
        
            resolved = struct;
            for i=1:length(desc.params)
                p = desc.params{i};
                
                exists = isfield(param_values, p.Name);
                if exists
                    resolved.(p.Name) = param_values.(p.Name);
                    continue
                end
        
                if ~exists
                    if isa(p.DefaultValue, 'function_handle')
                        resolved.(p.Name) = p.DefaultValue(resolved);
                    else
                        resolved.(p.Name) =  p.DefaultValue;
                    end
                end
            end
        
        end



    end
end

