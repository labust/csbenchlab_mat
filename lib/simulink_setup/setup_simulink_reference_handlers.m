
function setup_simulink_reference_handlers(env_name, controllers, blocks)
    hws = get_param(env_name, 'modelworkspace');

    for i=1:length(controllers)

        c_info = controllers(i);
        b = blocks.controllers(i);
    
        if c_info.IsComposable
            components = c_info.Components;
        else
            components = c_info;
        end

        scenario = hws.getVariable('ActiveScenario');
    
        for j=1:length(components)
            comp = components(j);
            b_comp = b.Components(j);            

            % set ref extractor const
            ref_value = 1;
            if is_valid_field(comp, 'RefHorizon')
                if isnumeric(comp.RefHorizon)
                    ref_value = comp.RefHorizon;
                % else, evaluate from params
                elseif ischar(comp.RefHorizon) || isstring(comp.RefHorizon)
                    if ~exist('comp_params', 'var')
                        comp_params = evalin('base', comp.Params);
                    end
                    ref_value = eval(strcat('comp_params.', comp.RefHorizon));
                end
            end
            if ref_value == 0
                ref_value = 1;
            end

            if is_valid_field(scenario, 'ConstHorizonReference')
                value = scenario.ConstHorizonReference;
                set_param(fullfile(b_comp.RefExtractor.Path, 'ConstantRef'), 'Value', mat2str(value));
            end

            if is_valid_field(comp.Mux, 'Inputs') && ~isempty(comp.Mux.Inputs)
                dims = comp.Mux.Inputs;
            else
                dims = linspace(1, blocks.systems.dims.Outputs, blocks.systems.dims.Outputs);
            end

            set_param(fullfile(b_comp.RefExtractor.Path, 'RefHorizonL'), 'Value', num2str(int32(ref_value)));
            set_param(fullfile(b_comp.RefExtractor.Path, 'RefDims'), 'Value', mat2str(dims));
            set_param(fullfile(b_comp.RefExtractor.Path, 'RefMemory'), 'InitialValue', ...
                    strcat('zeros(', num2str(int32(ref_value)), ', ', ...
                            num2str(length(dims)) ,')'));
        end
    end
end