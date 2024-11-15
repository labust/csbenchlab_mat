function handle = get_or_create_component_library(path, name)
    
    if ~exist(fullfile(path, name), 'dir')
        mkdir(fullfile(path, name));
    end

    syspath = [name, '_sys'];
    contpath = [name, '_ctl'];
    estpath = [name, '_est'];
    distpath = [name, '_dist'];
    handle = struct;
    handle.path = fullfile(path, name);
    handle.name = name;

    % only one check is enough for all 
    if ~exist(fullfile(path, name, [syspath '.slx']), 'file')
        handle.sh = new_system(syspath, 'Library');
        save_system(handle.sh, fullfile(path, name, syspath));
        handle.ch = new_system(contpath, 'Library');
        save_system(handle.ch, fullfile(path, name, contpath));
        handle.eh = new_system(estpath, 'Library');
        save_system(handle.eh, fullfile(path, name, estpath));
        handle.dh = new_system(distpath, 'Library');
        save_system(handle.dh, fullfile(path, name, distpath));
        registry.sys = {};
        registry.ctl = {};
        registry.est = {};
        registry.dist = {};
        version = 0.1;
        library = name;
        save(fullfile(handle.path, 'manifest.mat'), 'registry', 'version', 'library');

    else
        handle.sh = load_system(fullfile(path, name, syspath));
        handle.ch = load_system(fullfile(path, name, contpath));
        handle.eh = load_system(fullfile(path, name, estpath));
        handle.dh = load_system(fullfile(path, name, distpath));
    end

    set_param(handle.sh, 'Lock', 'off');
    set_param(handle.ch, 'Lock', 'off');
    set_param(handle.eh, 'Lock', 'off');
    set_param(handle.dh, 'Lock', 'off');
    

  
   
end