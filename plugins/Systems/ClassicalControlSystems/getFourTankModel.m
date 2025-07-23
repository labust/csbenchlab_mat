function sys = getFourTankModel()
%GETFOURTANKMODEL Returns the linearized four-tank system model.
%
%   sys = GETFOURTANKMODEL() returns a struct with fields A, B, C, D 
%   containing the state-space matrices of the four-tank system.
%
%   Linearized model is taken from:
%   P.C.N. Verheijen, V. Breschi, M. Lazar,
%   "Handbook of linear data-driven predictive control: Theory, implementation and design,"
%   Annual Reviews in Control, Volume 56, 2023, 100914.
%   DOI: https://doi.org/10.1016/j.arcontrol.2023.100914

    sys = struct;

    sys.A = [ 0.921  0      0.041  0;
              0      0.918  0      0.033;
              0      0      0.924  0;
              0      0      0      0.937 ];

    sys.B = [ 0.017  0.001;
              0.001  0.023;
              0      0.061;
              0.072  0     ];

    sys.C = [ 1  0  0  0;
              0  1  0  0 ];

    sys.D = zeros(2, 2);
end