classdef LogEntry
    
    properties
        Name
        EvalFn
    end
    
    methods
        function this = LogEntry(name, eval_fn)
            this.Name = name;
            if exist('eval_fn', 'var')
                this.EvalFn = fun2str(eval_fn);
            else
                this.EvalFn = strcat("@(x) x.", name); 
            end
        end
        
    end
end

