function sys = getLabPlantModel()
%GETLABPLANTMODEL Returns the lab-scale fifth-order plant model.
%
%   sys = GETLABPLANTMODEL() returns a struct with fields A, B, C, D
%   containing the discrete-time state-space matrices of a marginally
%   stable plant used in:
%
%   "Closed-loop Data-Enabled Predictive Control and its equivalence with 
%   Closed-loop Subspace Predictive Control", 
%   https://arxiv.org/abs/2402.14374
%
%   The system represents two circular plates connected by non-rigid shafts,
%   spun by a motor. It is often used for closed-loop identification and predictive
%   control experiments.

    sys = struct;

    sys.A = [ 4.40   1      0     0;
             -8.09   0      1     0;
              7.83   0      0     1;
              0.86   0      0     0 ];

    sys.B = [  0.00098;
               0.01299;
               0.01859;
              -0.00002 ];

    sys.C = [ 1; 0; 0; 0 ];

    sys.D = 0;
end