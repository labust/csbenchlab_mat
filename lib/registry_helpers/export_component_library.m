function export_component_library(lib_name)
    reg = get_app_registry_path();
    path = fullfile(reg, lib_name);
    

    copyfile(path, fullfile('export', lib_name));
    manifest = load(fullfile(path, 'manifest.mat'));

    components = [
        manifest.registry.sys{:}, ...
        manifest.registry.ctl{:}, ...
        manifest.registry.est{:}, ...
        manifest.registry.dist{:} ...
    ];
    src_path = fullfile('export', lib_name, 'src');

    for i=1:length(components)
        c = components(i);

        if strcmp(c.Type, 'slx')
            continue
        end

        if c.T == 1
            c_t = 'sys';
        elseif c.T == 2
            c_t = 'ctl';
        elseif c.T == 3
            c_t = 'est';
        elseif c.T == 4
            c_t = 'dist';
        end

        c_path = fullfile(src_path, c.Type, c_t);

        if strcmp(c.Type, 'm')
            path = which(c.Name);
            copyfile(path, c_path);
        elseif strcmp(c.Type, 'py')
            copyfile(c.Path, c_path);
        end
    end
end

