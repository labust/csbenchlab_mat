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

        function p = get_plugin_info(name, lib_name)
            lib_path = get_component_library(lib_name).Path;
           
            try
                manifest = load_lib_manifest(lib_path);
                registry = manifest.Registry;
            catch
                error(strcat("Manifest file not found for library '",  lib_name));
            end
            
            fns = fieldnames(registry);
            for i=1:length(fns)
                v = registry.(fns{i});
                for j=1:length(v)
                    if strcmp(v{j}.Name, name)
                        p = v{j};
                        return
                    end
                end
            end
            p = [];
        end


        function type_dict = generate_busses(name, params, data, log_desc, io_args, type_dict)
            m = ComponentManager;
            busses = {};
            % if data struct is valid
            if ~isnumeric(data) && ~isempty(fieldnames(data))
                busses = m.generate_bus_types_(name, '_DT', data, busses);
            end

            % if param struct is valid
            if ~isnumeric(params) && ~isempty(fieldnames(params))
                % generate bus data types for controller params
                busses = m.generate_bus_types_(name, '_PT', params, busses);     
            end

            % generate bus data types for logs
            new_log_bus = Simulink.Bus;
            for l=1:length(log_desc)
                d = log_desc{l};
                try 
                    value = data.(d.Name);
                catch
                    error(['Log entry "', d.Name, '" does not exist in the data model']);
                end
        
                el = Simulink.BusElement;
                el.Name = d.Name;
                el.DimensionsMode = "Fixed";
                el.Dimensions = size(value);
                new_log_bus.Elements(end+1) = el; 
            end
            log_bus_name = strcat(name, '_LT');
            busses{end+1} = struct('Name', log_bus_name, 'Bus', new_log_bus);

            % generate bus data types for inputs
            for l=1:length(io_args)
                a = io_args{l};
                
                if isa(a.Dim, 'function_handle')
                    if is_controller
                        dim = a.Dim(params, mux);
                    else
                        dim = a.Dim(params);
                    end
                else
                    dim = a.Dim;
                end
        
                if isa(dim, 'struct')
                    type_name = m.get_argument_type_name_(c_path, io_args{l}.Name);
                    busses = m.generate_input_bus_(type_name, dim, busses);
                end
            end

            for o=1:length(busses)
                type_dict = m.bus_add_override_(busses{o}.Name, busses{o}.Bus, type_dict);
            end
        end


        function type_dict = bus_add_override_(name, value, type_dict)
            if type_dict.exist(name)
                type_dict.deleteEntry(name);
            end
            type_dict.addEntry(name, value);
        end

        function busses = generate_bus_types_(block_name, name_sufix, data, busses)
            m = ComponentManager;
            if isnumeric(data)
                return
            end
            
            fields = fieldnames(data);
            new_data_bus = Simulink.Bus;
            for j=1:length(fields)
                name = fields(j);
                name = name{1};
                value = data.(name);
        
                el = Simulink.BusElement;
                el.Name = name;
                el.DimensionsMode = "Fixed";
                el.Dimensions = size(value);
                
                if isstring(value) || ischar(value)
                    error("String type is not supported by simulink. Use uint8 array instead");
                elseif isa(value, 'uint8')
                    el.DataType = 'uint8';
                elseif isa(value, 'struct')
                    busses = m.generate_bus_types_(strcat(block_name, '_', name), ...
                        name_sufix, value, busses);
                    el.DataType = strcat(block_name, '_', name, name_sufix);
                elseif isa(value, 'Indexer')
                    indexer_bus_s = m.create_indexer_(strcat(block_name, '_', name), value);
                    busses{end+1} = indexer_bus_s;
                    el.DataType = indexer_bus_s.Name;
                end
                new_data_bus.Elements(end+1) = el; 
            end
            new_data_bus_s.Name = strcat(block_name, name_sufix);
            new_data_bus_s.Bus = new_data_bus;
            busses{end+1} = new_data_bus_s;
        end
        
        
        function indexer_bus_s = create_indexer_(block_name, indexer)
            indexer_bus = Simulink.Bus;
            bel = Simulink.BusElement;
            bel.Name = 'b';
            bel.DimensionsMode = "Fixed";
            bel.Dimensions = 1;
            eel = Simulink.BusElement;
            eel.Name = 'e';
            eel.DimensionsMode = "Fixed";
            eel.Dimensions = 1;
            szel = Simulink.BusElement;
            szel.Name = 'sz';
            szel.DimensionsMode = "Fixed";
            szel.Dimensions = 1;
            rel = Simulink.BusElement;
            rel.Name = 'r';
            rel.DimensionsMode = "Fixed";
            rel.Dimensions = size(indexer.r);
            indexer_bus.Elements(1) = bel; 
            indexer_bus.Elements(2) = eel; 
            indexer_bus.Elements(3) = szel; 
            indexer_bus.Elements(4) = rel; 
            indexer_bus_s.Name = strcat(block_name, '_I'); 
            indexer_bus_s.Bus = indexer_bus;
        end

        function busses = generate_input_bus_(block_name, data, busses)
            m = ComponentManager;
            fields = fieldnames(data);
            new_data_bus = Simulink.Bus;
            for j=1:length(fields)
                name = fields(j);
                name = name{1};
                value = data.(name);
        
                el = Simulink.BusElement;
                el.Name = name;
                el.DimensionsMode = "Fixed";
                
        
                if isa(value, 'struct')
                    el.Dimensions = size(value);
                    busses = m.generate_bus_types_(strcat(block_name, '_', name), value, busses);
                    el.DataType = strcat(block_name, '_', name);
                else
                    el.Dimensions = value;
                end
                new_data_bus.Elements(end+1) = el; 
            end
            new_data_bus_s.Name = block_name;
            new_data_bus_s.Bus = new_data_bus;
            busses{end+1} = new_data_bus_s;
        end
        
        function replaced = replace_indexers_(data)
            m = ComponentManager;
            if isnumeric(data)
                replaced = data;
                return
            end
        
            fields = fieldnames(data);
            replaced = struct;
            for i = 1:length(data)
                for j=1:length(fields)
                    name = fields(j);
                    name = name{1};
                    value = data(i).(name);
            
                    if isa(value, 'struct')
                       replaced(i).(name) = m.replace_indexers_(value);
                    
                    elseif isa(value, 'Indexer')
                       replaced(i).(name).b = value.b;
                       replaced(i).(name).e = value.e;
                       replaced(i).(name).sz = value.sz;
                       replaced(i).(name).r = value.r;
                    else
                       replaced(i).(name) = value;
                    end
                end
            end
        end
    
    end
end