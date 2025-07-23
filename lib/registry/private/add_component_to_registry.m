function registry = add_component_to_registry(registry, p)
    if p.T == 1
        registry.sys{end+1} = p;
    elseif p.T == 2
        registry.ctl{end+1} = p;
    elseif p.T == 3
        registry.est{end+1} = p;
    elseif p.T == 4
        registry.dist{end+1} = p;
    end
end