function registry = add_component_to_registry(registry, p)
    registry.(p.T){end+1} = p;
end