classdef ParseRgx


    properties (Constant)
        FunctionCall = '[a-zA-Z_]+\([^\)]*\)(\.[^\)]*\))?'
        FunctionArgList = '\(\s*([^)]+?)\s*\)'
    end
end

