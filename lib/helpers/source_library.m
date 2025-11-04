function source_library(lib_path, lib_name)
    paths = get_library_folder_paths(lib_path, lib_name);
    addpath(paths{:});
end

