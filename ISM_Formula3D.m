%%
% Stefan Bilbao, Benoit Alary
%
% ISM_Formula3D.m
%
% Example code demonstrating the direction-dependent reverberation
% formula detailed in the following article :
%
% S. Bilbao, B. Alary,
% "Directional Reverberation Time and the Image Source Method for Rectangular Parallelepipedal Rooms",
% J. Acoust. Soc. Am. 1 February 2024; 155 (2): 1343–1352. 
% https://doi.org/10.1121/10.0024975
% 
%
% Input:
%              L_v : Shoebox room dimensions vector [length x, length y, length z]
%               Z0 : Normalized wall impedance vector [x+, y+, z+, x-, y-, z-]
%           s_grid : [X, Y, Z], cartesian coordinate of the sphere sampling grid
% isAngleDependent : set to 'true' to use angle-dependent absorption
%
%

function RT60 = ISM_Formula3D(L_v, Z0, s_grid, isAngleDependent)

    %% Calculate the exponential slope corresponding to each directions
    % (see eq.28) 
    K = DirectionalSlope(s_grid, L_v, Z0, isAngleDependent);
    %% Convert to reverberation time
    RT60 = CalculateRT60( K );
    
end

function K = DirectionalSlope(s_grid, L_v, Z0, isAngleDependent)

    %% See equation 29:
	% S. Bilbao, B. Alary,
	% "Directional Reverberation Time and the Image Source Method for Rectangular Parallelepipedal Rooms",
	% J. Acoust. Soc. Am. 1 February 2024; 155 (2): 1343–1352. 
	% https://doi.org/10.1121/10.0024975

    % Z0 corresponds to the normalized impedance for each walls, 
    % aligned to a cartesian grid, in the following order
    % [x+, y+, z+, x-, y-, z-]
   
    %% Speed of sound
    c = 343;

    %% initialize
    K = zeros(size(s_grid.X));

    %% Calculating the two summations of eq.29

    % +,-: x 'walls'
    K = AbsorptionSlope(Z0(1), s_grid.X, L_v(1), isAngleDependent);
    K = K + AbsorptionSlope(Z0(4), s_grid.X, L_v(1), isAngleDependent);

    % +,-: y 'walls'
    K = K + AbsorptionSlope(Z0(2), s_grid.Y, L_v(2), isAngleDependent);
    K = K + AbsorptionSlope(Z0(5), s_grid.Y, L_v(2), isAngleDependent);
    
    % +,-: z 'walls'
    K = K + AbsorptionSlope(Z0(3), s_grid.Z, L_v(3), isAngleDependent);
    K = K + AbsorptionSlope(Z0(6), s_grid.Z, L_v(3), isAngleDependent);

    %% Finalize K calculations
    K = -c .* K;
end

function K_partial = AbsorptionSlope(Z_alpha, u_v, L_v, isAngleDependent)
    
    %% See inside component of equation 29:
	% S. Bilbao, B. Alary,
	% "Directional Reverberation Time and the Image Source Method for Rectangular Parallelepipedal Rooms",
	% J. Acoust. Soc. Am. 1 February 2024; 155 (2): 1343–1352. 
	% https://doi.org/10.1121/10.0024975

    if isAngleDependent
        beta_alpha = (Z_alpha .* abs(u_v) - 1) ./ (Z_alpha .* abs(u_v) + 1);
    else
        %% see equation 25
        a_alpha = ImpedanceToRandomAbsorption(Z_alpha);
        beta_alpha = sqrt(1 - a_alpha);
    end

    K_partial = log( abs(beta_alpha) ) .* abs(u_v) ./ L_v;
end

function RT60 = CalculateRT60(K)

    %% See equation 34:
	% S. Bilbao, B. Alary,
	% "Directional Reverberation Time and the Image Source Method for Rectangular Parallelepipedal Rooms",
	% J. Acoust. Soc. Am. 1 February 2024; 155 (2): 1343–1352. 
	% https://doi.org/10.1121/10.0024975

    % Convert exponential decay to reverberation time
    RT60 = (6*log(10)) ./ K;
end

function alpha_e = ImpedanceToRandomAbsorption(Z0)
    
    %% Converting wall impedance to random incidence absorption
    %
    % From: 
    % Albert London,
    % The Determination of Reverberant Sound Absorption Coefficients from Acoustic Impedance Measurements. 
    % J. Acoust. Soc. Am. 1 March 1950; 22 (2): 263–269. 

    % normal incidence:
    % eq.8
    a0 = 1 - ((Z0 - 1) ./ (Z0 + 1)).^2;

    % eq.12
    b = sqrt(1 - a0);
    alpha_e = 4 * ((1 - b) / (1 + b)) * (log(2) - 1/2 - log(1 - b) - b/2);
end


