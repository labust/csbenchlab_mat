function create_export_cdf_file(info, type, path)
    
    s.Name = info.Name;
    s.Id = info.Id;
    s.Type = type;
    
    if isfield(info, 'Lib')
        s.Lib = info.Lib;
        s.LibVersion = info.LibVersion;
    end

    writestruct(s, fullfile(path, strcat(info.Name, '.cdf')), 'FileType', 'json');

end