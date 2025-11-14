function comp = load_casadi_component(comp_path)
    import casadi.*
    
    comp = struct;
        
    comp.step_fns = {};

    i = 1;
    while 1
        fname = fullfile(comp_path, strcat('step_', num2str(i), '.casadi'));
        if exist(fname, 'file')
            comp.step_fns{end+1} = Function.load(fname);
        else
            break
        end
        i = i + 1;
    end
    comp.step = @step;
    comp.configure = @configure;
end


function configure()

end

function [comp, u] = step(comp, y_ref, y, dt)
    d = dictionary;
    d('y_ref') = {y_ref};
    d('y') = {y};
    d('dt') = {dt};
    data = comp.data;
    fns = fieldnames(data);
    for i=1:length(fns)
        d(fns{i}) = {data.(fns{i})};
    end
    for i=1:length(comp.step_fns)
        inputs = prepare_inputs(comp.step_fns{i}, d);
        % result = cell(length(comp.step_fns{i}.name_out()), 1);
        result = comp.step_fns{i}(inputs{:});
        d = update_inputs(result, d);
    end
    u = result.out.full();
    new_data = update_data(result, data);
    comp.data = new_data;
end

function d = update_inputs(out, d)
    fns = fieldnames(out);
    for i=1:length(fns)
        d(fns{i}) = {out.(fns{i})};
    end

end

function inputs = prepare_inputs(fn, d)

    names = fn.name_in();
    inputs = {};
    for i=1:height(names)
        v = nonzeros(names(i, :))';
        if d.isKey(v)
            cv = d(v);
            inputs{end+1} = v;
            inputs{end+1} = casadi.DM(cv{1});
        end
        % inputs{i} = set_value;
    end
end

function data = update_data(new_data, data)
    fns = fieldnames(data);

    for i=1:length(fns)
        if isfield(new_data, fns{i})
            data.(fns{i}) = new_data.(fns{i}).full();
        elseif isfield(new_data, strcat('new_', fns{i}))
            data.(fns{i}) = new_data.(strcat('new_', fns{i})).full();
        end

    end
end