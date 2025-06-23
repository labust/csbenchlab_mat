classdef EvalParam
    %PARAMETER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        EvalFn
        EvalArgs
    end

    methods(Static)
        function c = from_string(str)
            str = convertStringsToChars(str);
            [i, j] = regexp(str, ParseRgx.FunctionCall);
            str = str(i:j);
            name = split(str, '(');
            name = name{1};
            args = regexp(str, ParseRgx.FunctionArgList, "tokens");
            args = split(args{1}{1}, ', ');
            c = EvalParam(name, args{:});
        end
    end
    
    methods
        function this = EvalParam(fn, varargin)
            this.EvalFn = fn;
            this.EvalArgs = varargin2stringarray(varargin{:});
        end

        function disp(this)   
            if isempty(this.EvalArgs)
                args = '';
            else
                args = strjoin(this.EvalArgs, ', ');
            end
            fprintf(...
                strcat(this.EvalFn,'(', args, ')\n'));            
        end
    end
end

