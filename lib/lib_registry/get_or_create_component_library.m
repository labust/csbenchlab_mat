function handle = get_or_create_component_library(lib_name, close_after_creation)
    
    try
        path = get_library_path(lib_name);
    catch
        path = fullfile(CSPath.get_app_registry_path, lib_name);
    end

    if ~exist(fullfile(path), 'dir')
        mkdir(fullfile(path));
    end
    
    autogen_folder = fullfile(path, 'autogen');
    autogen_created = 0;
    if ~exist(autogen_folder, 'dir')
        autogen_created = 1;
        mkdir(autogen_folder);
    end

    if ~exist('close_after_creation', 'var')
        close_after_creation = 0;
    end

    syspath = strcat(lib_name, '_sys');
    contpath = strcat(lib_name, '_ctl');
    estpath = strcat(lib_name, '_est');
    distpath = strcat(lib_name, '_dist');
    handle = struct;
    handle.path = path;
    handle.name = lib_name;

    % check if package is already created
    if autogen_created
        close_library(lib_name);
        handle = create_component_library(path, 0);
    else
        handle.sh = load_and_unlock_system(fullfile(autogen_folder, syspath));
        handle.ch = load_and_unlock_system(fullfile(autogen_folder, contpath));
        handle.eh = load_and_unlock_system(fullfile(autogen_folder, estpath));
        handle.dh = load_and_unlock_system(fullfile(autogen_folder, distpath));
    end
    
    if close_after_creation > 0
        close_system(handle.sh);
        close_system(handle.ch);
        close_system(handle.eh);
        close_system(handle.dh);
    end

end
