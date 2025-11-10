classdef ComponentRegister


    methods (Static)
        function cls = get(comp)
            if is_component_type(comp, 'mat')
                cls = MatComponentRegister;
            elseif is_component_type(comp, 'slx')
                cls = SlxComponentRegister;
            elseif is_component_type(comp, 'py')
                cls = PyComponentRegister;
            else
                error('Unknown component register');
            end
        end

        function ext = get_supported_plugin_types()
            ext = ["mat", "slx", "py"];
        end

        function ext = get_supported_plugin_file_extensions()
            ext = [".m", ".slx", ".py"];
        end

        function typ = get_plugin_type_from_file(component_path)
            splits = split(component_path, ':');
            component_path = splits{1};
        
            [~, ~, ext] = fileparts(component_path);
                
            if strcmp(ext, '.m')
                typ = "mat";
            elseif strcmp(ext, '.slx')
                typ = "slx";
            elseif strcmp(ext, '.py')
                typ = "py";
            else
                error("Error identifying plugin from file. Unknown plugin type.")
            end
        end

        function info = unregister(name, lib_name)
            info = get_plugin_info_from_lib(name, lib_name);
            if isempty(info)
                error(strcat("Component '", name, "' does not exist in library" + ...
                    " '", lib_name, "'."))
            end
            ComponentRegister.unregister_component_(name, lib_name, info.T);
        end

        function unregister_component_(name, lib_name, typ)
            n = strcat(lib_name, '_', typ);
            block_path = fullfile(n, name);
            load_and_unlock_system(n);
            try
                delete_block(block_path);
                save_system(n);
            catch
            end
            close_system(n);
        end

    end
end