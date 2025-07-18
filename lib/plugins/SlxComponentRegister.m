classdef SlxComponentRegister < ComponentRegister
    %SLXCOMPONENTREGISTER Summary of this class goes here
    %   Detailed explanation goes here

    
    methods (Static)
        function info = get_plugin_info(model_name, component_path)
            info = struct;
            info.T = 0;

            splits = split(component_path, ':');
            if length(splits) > 1
                rel_path = splits{2};
            end
            
            n_split = split(rel_path, '/');
        
            info.Name = n_split{end};
            h_first = getSimulinkBlockHandle(fullfile(model_name, rel_path));
            if h_first == -1
                load_system(model_name);
                h = getSimulinkBlockHandle(fullfile(model_name, rel_path));
            else
                h = h_first;
            end
        
            if h == -1
                close_system(model_name, 0);
                error(strcat("Model block '", model_name, ":", rel_path, "' does not exist"));
            end
            inputs = get(find_system(h, 'FindAll', 'On', 'LookUnderMasks', 'on', 'SearchDepth', 1, 'BlockType', 'Inport' ), 'Name');
            outputs = get(find_system(h, 'FindAll', 'On', 'LookUnderMasks', 'on', 'SearchDepth', 1, 'BlockType', 'Outport' ), 'Name');
            if SlxComponentRegister.is_sys(inputs, outputs)
                info.T = 1;
            elseif SlxComponentRegister.is_ctl(inputs, outputs)
                info.T = 2;
            elseif SlxComponentRegister.is_est(inputs, outputs)
                info.T = 3;
            elseif SlxComponentRegister.is_dist(inputs, outputs)
                info.T = 4;
            end
            info.model_name = model_name;
            info.rel_path = rel_path;
        
            if h_first == -1
                close_system(model_name, 0);
            end
        end
        
        
        function t = is_sys(inputs, outputs)
            t = 0;
            if length(inputs) < 4 || length(outputs) < 1
                return
            end
            t = strcmpi(inputs{1}, 'u') && strcmpi(inputs{2}, 't') ...
                && strcmpi(inputs{3}, 'dt') && strcmpi(inputs{4}, 'ic') ...
                && strcmpi(outputs, 'y');
        end
        
        
        function t = is_ctl(inputs, outputs)
            t = 0;
            if length(inputs) < 3 || length(outputs) < 2
                return
            end
            t = strcmpi(inputs{1}, 'y_ref') && strcmpi(inputs{2}, 'y') ...
                && strcmpi(inputs{3}, 'dt') && strcmpi(outputs{1}, 'u') ...
                && strcmpi(outputs{2}, 'log');
        end
        
        function t = is_est(inputs, outputs)
            t = 0;
            if length(inputs) < 3 || length(outputs) < 1
                return
            end
            t = strcmpi(inputs{1}, 'y') && strcmpi(inputs{2}, 'dt') ...
                && strcmpi(inputs{3}, 'ic') && strcmpi(outputs{1}, 'y_hat');
        end
        
        function t = is_dist(inputs, outputs)
            t = 0;
            if length(inputs) < 2 || length(outputs) < 1
                return
            end
            t = strcmpi(inputs{1}, 'y') && strcmpi(inputs{2}, 'dt') ...
                && strcmpi(outputs{1}, 'y_n');
        end


        function register(info, t, lib_name)
            if t == 1
               SlxComponentRegister.register_slx_component_(info, 'sys', lib_name, { '__cs_slx_sys' });
           elseif t == 2
               SlxComponentRegister.register_slx_component_(info, 'ctl', lib_name, { '__cs_slx_ctl' });
           elseif t == 3
               SlxComponentRegister.register_slx_component_(info, 'est', lib_name, { '__cs_slx_est' });
           elseif t == 4
               SlxComponentRegister.register_slx_component_(info, 'dist', lib_name, { '__cs_slx_dist' });
           end
        end

        function register_slx_component_(info, typ, lib_name, tags, size)
            load_system(info.model_name);
            src = fullfile(info.model_name, info.rel_path);
            splits = split(info.rel_path, '/');
            name = splits{end};
            dest = strcat(lib_name, '_', typ);
            load_system(dest);
            
            GRID_LEN = 4;
            count = length(find_system(dest, 'SearchDepth', 1)) - 1;
            idx_j = floor(count / GRID_LEN) + 1;
            idx_i = mod(count, GRID_LEN) + 1;
            dl = 200;
            if ~exist("size", 'var')
                size = [80, 50];
            end
            position = [idx_i * dl, idx_j * dl, idx_i * dl + size(1), idx_j * dl + size(2)]';
        
            load_and_unlock_system(dest);
            
            % delete block if exists
        
            dest_path = fullfile(dest, name);
            handle = getSimulinkBlockHandle(dest_path);
            if handle ~= -1
                delete_block(dest_path);    
            end
            try
                block = add_block(src, dest_path);
                block_name = get_param(block, 'Name');
                set_param(block, 'Position', position);
                for i=1:length(tags)
                    model_append_tag(block, tags{i});
                end
                
                % break link with file
                % required for mask parameter changes
                set_param(block, 'LinkStatus', 'none'); 
                mask_parameters  = struct('Name', 'params_struct_name', ...
                    'Value', '', 'Visible', 'off', 'Prompt', '', 'Evaluate', 'off');

                % does not work on linked blocks - TODO
                set_block_mask_parameters(block, block_name, [ ...
                    get_component_default_mask_params(info, lib_name, 0), mask_parameters]);
        
                save_system(dest);
            catch ME
                close_system(info.model_name, 0);
                close_system(dest, 0);
                rethrow(ME);
            end
            close_system(info.model_name, 0);
            close_system(dest, 0);
        end

    




        

    end
end

