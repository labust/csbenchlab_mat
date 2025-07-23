function id = check_cdf_library_exists(cdf_path)
    
    try
        cdf = readstruct(cdf_path, 'FileType','json');
    catch
        error("Cannot import component. A file name *.cdf does not exist on path");
    end

    libs = list_component_libraries();
    id = "";
    for i=1:length(libs)
        if strcmp(cdf.Lib, libs(i).Name)
            id = cdf.Id;
            return
        end
    end
    
    error('The component library is not registered');

end