function it_list = environment_components_it(info)
    
    it_list = {};
    
    it_list{end+1} = new_node(info.System, []);
    it_list = add_subcomponents_(info.System, it_list);
    for i=1:length(info.Controllers)
        ctl = info.Controllers(i);           
        it_list{end+1} = new_node(ctl, []);
        it_list = add_subcomponents_(ctl, it_list);
    end
    for i=1:length(info.Scenarios)
        sc = info.Scenarios(i);
        it_list{end+1} = new_node(sc, []);
        it_list = add_subcomponents_(sc, it_list);
    end
    for i=1:length(info.Metrics)
        m = info.Metrics(i);
        it_list = add_subcomponents_(m, it_list);
    end
end

function r = new_node(n, p) 
    r = struct('n', n, 'p', p);
end


function it_list = add_subcomponents_(comp, it_list)
    if is_valid_field(comp, 'Subcomponents')
        for i=1:length(comp.Subcomponents)
            if ~is_valid_field(comp, comp.Subcomponents(i))
                continue
            end
            c = comp.(comp.Subcomponents(i));
            for j=1:length(c)
                it_list{end+1} = new_node(c(i), comp);
            end
        end
    end

end

