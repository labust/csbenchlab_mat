classdef SlxComponentManager < ComponentManager
    %PYSETUPCOMPONENT Summary of this class goes here
    %   Detailed explanation goes here
    
   
    methods (Static)
        function resolved = get_component_params(comp_name, lib_name, param_values)

            if ~exist('param_values', 'var')
                param_values = struct;
            end
            
            info = get_plugin_info_from_lib(comp_name, lib_name);
            if info.T == 1
                e = 'sys';
            elseif info.T == 2
                e = 'ctl';
            elseif info.T == 3
                e = 'est';
            elseif info.T == 4
                e = 'dist';
            end
            
            model_name = strcat(lib_name, '_', e);
            slx_path = which(model_name);
            if strempty(slx_path)
                error(strcat("Cannot load parameters for component '", comp_name, ...
                    "' in library '", lib_name, "'. Check that it is on matlab path"));
            end
            load_system(slx_path);
        
            h = getSimulinkBlockHandle(fullfile(model_name, comp_name));
            
            mo = get_param(h, 'MaskObject');
            
                
            resolved = {};
            if ~isempty(mo)    
                for i=1:length(mo.Parameters)
                    p = mo.Parameters(i);
                    if strcmp(p.Visible, 'on') && ~strcmp(p.Name, 'params')
                        resolved{end+1} = ParamDescriptor(p.Name, str2double(p.Value));
                    end
                end
            end
            close_system(slx_path);
        end


        function type_dict = setup_component(c_path, type_dict, ~)

            params = get_component_params_from_block(c_path);
            try
                params_struct_name = get_mask_value(c_path, 'params_struct_name');
            catch
                return
            end

            mo = get_param(c_path, 'MaskObject');
            for i=1:length(mo.Parameters)
                p = mo.Parameters(i);
                if strcmp(p.Visible, 'off')
                    continue
                end
                
                if ~isfield(params, p.Name)
                    continue
                end
                mo.Parameters(i).Value = strcat(params_struct_name, '.', p.Name);
            end
        end

    end
end

