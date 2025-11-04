function source_libraries()

    libs = list_component_libraries();
    for i=1:length(libs)
        source_library(libs(i).Path, libs(i).Name);
    end
end

