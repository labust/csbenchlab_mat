function on_model_load_impl()
    pa = @BlockHelpers.path_append;
    curr_model = gcs;
    setup_simulink_with_controllers(curr_model);

    % setup reference extractors

    folder_path = fileparts(which(curr_model));
   
    loaded = load(pa(folder_path, 'autogen', strcat(curr_model, '.mat')));
    info = loaded.env_info;
    blocks = loaded.blocks;

    for i=1:length(info.Controllers)
        c_info = info.Controllers(i);
        b = blocks.controllers(i);
    
        if is_valid_field(c_info, 'Components')
            components = c_info.Components;
        else
            components = c_info;
        end
    
        for j=1:length(components)
            comp = components(j);
            b_comp = b.Components(j);

            comp_params = evalin('base', comp.Params);
            

            % set ref extractor const
            ref_value = 1;
            if is_valid_field(comp, 'RefHorizon')
                if isnumeric(comp.RefHorizon)
                    ref_value = comp.RefHorizon;
                % else, evaluate from params
                elseif ischar(comp.RefHorizon) || isstring(comp.RefHorizon) 
                    ref_value = eval(strcat('comp_params.', comp.RefHorizon));
                end
            end

            if is_valid_field(comp, 'ConstantRef')
                if isnumeric(comp.ConstantRef)
                    value = comp.ConstantRef;
                % else, evaluate from params
                elseif ischar(comp.ConstantRef) || isstring(comp.ConstantRef) 
                    value = eval(strcat('comp_params.', comp.ConstantRef));
                end
                set_param(pa(b_comp.RefExtractor.Path, 'ConstantRef'), 'Value', mat2str(value));
            end

            set_param(pa(b_comp.RefExtractor.Path, 'RefHorizonL'), 'Value', num2str(int32(ref_value)));
            set_param(pa(b_comp.RefExtractor.Path, 'RefDims'), 'Value', mat2str(comp.Mux.Input));
            set_param(pa(b_comp.RefExtractor.Path, 'RefMemory'), 'InitialValue', ...
                    strcat('zeros(', num2str(int32(ref_value)), ', ', ...
                            num2str(length(comp.Mux.Input)) ,')'));
        end
    end
    open_system(strcat(curr_model, '/RefGenerator'));

end

