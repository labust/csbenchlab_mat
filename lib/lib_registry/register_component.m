function ret = register_component(info, lib_name, append_to_json, append_to_manifest)
   
   t = info.T;
   lib_path = get_library_path(lib_name);
   if ~strcmp(lib_name, 'csbenchlab') &&~startsWith(info.ComponentPath, lib_path) 
       error(['Cannot register component. Component source file should be inside ' ...
           'the library.'])
   end

   if ~exist('append_to_json', 'var')
       append_to_json = 1;
   end

   if ~exist('append_to_manifest', 'var')
       append_to_manifest = 1;
   end
   
   r = ComponentRegister.get(info.Type);
   r.register(info, t, lib_name);
   
   info.Lib = lib_name;
    
   if append_to_manifest
       add_to_lib_manifest(info, info.T, lib_name);
   end

   if append_to_json
       append_to_plugin_json(info, lib_path);
   end
   ret = 1;
end


function append_to_plugin_json(info, lib_path)

    json_path = fullfile(lib_path, 'plugins.json');
    s = readstruct(json_path);
    if strcmp(info.Lib, 'csbenchlab')
        p = fileparts(lib_path);
        p = fileparts(p);
        rel_path = char(strrep(info.ComponentPath, p, ''));
    else
        rel_path = char(strrep(info.ComponentPath, lib_path, ''));
    end
    
    if startsWith(rel_path, '/')
        rel_path = rel_path(2:end); % remove 
    end
    new_s = struct('Type', "file", "Path", rel_path, 'Name', info.Name);
    if isempty(s.Plugins)
        s.Plugins = new_s;
    else
        s.Plugins(end+1) = new_s;
    end
    writestruct(s, json_path);
end
