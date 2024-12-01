function handle = get_or_create_component_library(path, name, close_after_creation)
    
    if ~exist(fullfile(path, name), 'dir')
        mkdir(fullfile(path, name));
    end

    if ~exist('close_after_creation', 'var')
        close_after_creation = 0;
    end

    syspath = [name, '_sys'];
    contpath = [name, '_ctl'];
    estpath = [name, '_est'];
    distpath = [name, '_dist'];
    handle = struct;
    handle.path = fullfile(path, name);
    handle.name = name;

    % only one check is enough for all 
    if ~exist(fullfile(path, name, 'manifest.mat'), 'file')
        handle.sh = new_system(syspath, 'Library');
        save_system(handle.sh, fullfile(path, name, syspath));
        handle.ch = new_system(contpath, 'Library');
        save_system(handle.ch, fullfile(path, name, contpath));
        handle.eh = new_system(estpath, 'Library');
        save_system(handle.eh, fullfile(path, name, estpath));
        handle.dh = new_system(distpath, 'Library');
        save_system(handle.dh, fullfile(path, name, distpath));
        make_component_dirs(fullfile(path, name, 'src', 'm'));
        make_component_dirs(fullfile(path, name, 'src', 'py'));
        mkdir(fullfile(path, name, name));
        registry.sys = {};
        registry.ctl = {};
        registry.est = {};
        registry.dist = {};
        version = 0.1;
        library = name;
        addpath(fullfile(path, name));
        addpath(fullfile(path, name, name));
        save(fullfile(handle.path, 'manifest.mat'), 'registry', 'version', 'library');
    else
        handle.sh = load_and_unlock_system(fullfile(path, name, syspath));
        handle.ch = load_and_unlock_system(fullfile(path, name, contpath));
        handle.eh = load_and_unlock_system(fullfile(path, name, estpath));
        handle.dh = load_and_unlock_system(fullfile(path, name, distpath));
    end
    

    if close_after_creation > 0
        close_system(handle.sh);
        close_system(handle.ch);
        close_system(handle.eh);
        close_system(handle.dh);
    end

end


function make_component_dirs(path)
    mkdir(fullfile(path, 'sys'));
    mkdir(fullfile(path, 'ctl'));
    mkdir(fullfile(path, 'est'));
    mkdir(fullfile(path, 'dist'));
end