function handle = create_component_library(path, close_after_creation)
    
    if nargin == 0
        dest_path = '.';
        [~, name, ~]= fileparts(pwd);
        close_after_creation = 1;
    else
        if endsWith(path, '/')
            path = path(1:end-1);
        end
        dest_path = path;
        [~, name, ~]= fileparts(dest_path);
    end

    if ~exist(dest_path, 'dir')
        mkdir(dest_path);
    end
    
    autogen_folder = fullfile(dest_path, 'autogen');
    if ~exist(autogen_folder, 'dir')
        mkdir(autogen_folder);
    end

    if ~exist('close_after_creation', 'var')
        close_after_creation = 1;
    end


    syspath = strcat(name, '_sys');
    contpath = strcat(name, '_ctl');
    estpath = strcat(name, '_est');
    distpath = strcat(name, '_dist');
    handle = struct;
    handle.path = dest_path;
    handle.name = name;

    handle.sh = new_system(syspath, 'Library');
    save_system(handle.sh, fullfile(autogen_folder, syspath));
    handle.ch = new_system(contpath, 'Library');
    save_system(handle.ch, fullfile(autogen_folder, contpath));
    handle.eh = new_system(estpath, 'Library');
    save_system(handle.eh, fullfile(autogen_folder, estpath));
    handle.dh = new_system(distpath, 'Library');
    save_system(handle.dh, fullfile(autogen_folder, distpath));

    make_folder(fullfile(dest_path, 'src'));
    make_folder(fullfile(dest_path, name))

    comp_types = get_component_types();

    for i=1:length(comp_types)
        registry.(comp_types(i)) = {};
    end

    library = name;
    lib_meta.library = library;
    lib_meta.version = "0.0.1";
    addpath(dest_path);
    addpath(fullfile(dest_path, 'autogen'));
    addpath(fullfile(dest_path, name));
    save(fullfile(handle.path, 'autogen', 'manifest.mat'), 'registry');
    writestruct(lib_meta, fullfile(handle.path, 'package.json'));

    if ~isfile(fullfile(handle.path, 'plugins.json'))
        
        content = fileread(fullfile(CSPath.get_app_template_path(), 'plugins_template.json'));
        replaced = replace(content, '{{library_name}}', name);
        try
            fid = fopen(fullfile(handle.path, 'plugins.json'),'wt');
            fprintf(fid, replaced);
            fclose(fid);
        catch
        end
    end

    if close_after_creation > 0
        close_system(handle.sh);
        close_system(handle.ch);
        close_system(handle.eh);
        close_system(handle.dh);
    end
end


function make_folder(path)
    if ~isfolder(path)
        mkdir(path)
    end
end