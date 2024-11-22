function arg_description = create_argument_description(arguments)
    arg_description = cellfun(@(x) struct('Name', x, 'Tunable', 1, 'DataType', '', 'Scope', ''), arguments);
end

