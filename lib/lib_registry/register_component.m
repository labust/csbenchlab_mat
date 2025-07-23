function register_component(info, t, lib_name, lib_path, append_to_json)
   
   if ~strcmp(lib_name, 'csbenchlab') &&~startsWith(info.ComponentPath, lib_path) 
       error(['Cannot register component. Component source file should be inside ' ...
           'the library.'])
   end

   if ~exist('append_to_json', 'var')
       append_to_json = 1;
   end
   
   r = ComponentRegister.get(info.Type);
   r.register(info, t, lib_name);

   if append_to_json
       append_to_plugin_json(info, t, lib_path);
   end
end


function append_to_plugin_json(info, t, lib_path)

    json_path = fullfile(lib_path, 'plugins.json');
    s = readstruct(json_path);
    rel_path = strrep(info.ComponentPath, lib_path, '');
    
    if startsWith(rel_path, '/')
        rel_path = rel_path(2:end); % remove 
    end
    new_s = struct('type', "file", "path", rel_path, 'name', info.Name);
    if isempty(s.plugins)
        s.plugins = new_s;
    else
        s.plugins(end+1) = new_s;
    end
    writestruct(s, json_path);
end
