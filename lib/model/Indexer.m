classdef Indexer

    properties
        b
        e
        sz
        r
    end
    methods
        function this = Indexer(b, e)
            if e < b 
                error('Indexer error. End is less than begin.');
            end
            this.b = b;
            this.e = e;
            this.sz = e-b+1;
            this.r = b:e;
        end
    end
end

