function dx = fourTankNonlinearModel(t, x, u)
%FOURTANKNONLINEARMODEL Nonlinear state-space model of the four tank system.
%
%   dx = FOURTANKNONLINEARMODEL(t, x, u) computes the time derivative
%   of the state vector x for input u at time t, according to the
%   nonlinear model from:
%
%   T. Raff, S. Huber, Z.K. Nagy, F. Allgöwer,
%   "Nonlinear model predictive control of a four tank system:
%    An experimental stability study," ACC 2006.
%
%   Inputs:
%       t - time (not used, included for ODE compatibility)
%       x - state vector [x1; x2; x3; x4] (water heights in cm)
%       u - input vector [u1; u2] (pump flows in cm³/s)
%
%   Output:
%       dx - time derivative of the state vector

    % Physical constants
    g = 981;  % cm/s²

    % Tank cross-sectional areas Ai (cm²)
    A1 = 50.27; A2 = 50.27;
    A3 = 28.27; A4 = 28.27;

    % Outlet hole areas ai (cm²)
    a1 = 0.233; a2 = 0.242;
    a3 = 0.127; a4 = 0.127;

    % Valve coefficients
    gamma1 = 0.4;
    gamma2 = 0.4;

    % State variables
    x1 = x(1); x2 = x(2); x3 = x(3); x4 = x(4);

    % Inputs
    u1 = u(1);
    u2 = u(2);

    % Dynamics
    dx = zeros(4,1);
    dx(1) = -a1/A1 * sqrt(2*g*x1) + a3/A1 * sqrt(2*g*x3) + gamma1/A1 * u1;
    dx(2) = -a2/A2 * sqrt(2*g*x2) + a4/A2 * sqrt(2*g*x4) + gamma2/A2 * u2;
    dx(3) = -a3/A3 * sqrt(2*g*x3) + (1 - gamma2)/A3 * u2;
    dx(4) = -a4/A4 * sqrt(2*g*x4) + (1 - gamma1)/A4 * u1;
end