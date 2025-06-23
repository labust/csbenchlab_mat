classdef ComponentManager


    methods (Static)
        function cls = get(comp)
            if is_component_type(comp, 'mat')
                cls = MatComponentManager;
            elseif is_component_type(comp, 'slx')
                cls = SlxComponentManager;
            elseif is_component_type(comp, 'py')
                cls = PyComponentManager;
            else
                error('Unknown component manager');
            end
        end

        function ext = get_supported_plugin_types()
            ext = ["mat", "slx", "py"];
        end

        function ext = get_supported_plugin_file_extensions()
            ext = [".m", ".slx", ".py"];
        end


    end
end