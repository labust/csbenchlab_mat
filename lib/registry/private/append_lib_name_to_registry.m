function registry = append_lib_name_to_registry(registry, lib_name)
    
    fns = fieldnames(registry);
    for i=1:length(fns)
        n = fns{i};
        for j=1:length(registry.(n))
            registry.(n){j}.Lib = lib_name;
        end
    end
end