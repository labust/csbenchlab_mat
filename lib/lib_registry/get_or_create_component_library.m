function handle = get_or_create_component_library(path, close_after_creation)
    
    [~, name, ~] = fileparts(path); 

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

    syspath = strcat(name, '_sys');
    contpath = strcat(name, '_ctl');
    estpath = strcat(name, '_est');
    distpath = strcat(name, '_dist');
    handle = struct;
    handle.path = path;
    handle.name = name;

    % check if package is already created
    if autogen_created
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
