function m = get_python_module_from_file(module_name, file_path)
    
    persistent module_dict

    if isempty(module_dict)
        module_dict = dictionary;
    end

    if module_dict.numEntries == 0 || ...
        ~module_dict.isKey(pid)

        [folder, name, ~] = fileparts(file_path);


        pysrc = CSPath.get_app_python_src_path();
        [pardir, ~, ~] = fileparts(pysrc);
        
        evalin('base', strcat('insert(py.sys.path, int64(0), "', pardir, '");'))
        evalin('base', strcat('insert(py.sys.path, int64(0), "', folder, '");'))
        m = evalin('base', strcat("py.importlib.import_module('", module_name, "');"));
        evalin('base', 'pop(py.sys.path, int64(0));');
        if ~py.hasattr(m, name)
            error(strcat("Error loading plugin. Plugin with name '", module_name, "' does not exist"));
        end
        module_dict(pid) = m;
    else
        m = module_dict(pid);
    end
end