%%
% Stefan Bilbao, Benoit Alary
%
% figure2_examples.m
%
% Example code demonstrating how to use the direction-dependent reverberation
% formula detailed in the following article :
%
% S. Bilbao, B. Alary,
% Directional Reverberation Time and the Image Source Method for Rectangular Parallelepipedal Rooms 
% accepted for publication in J. Acoust. Soc. Am. X X 2024; XX (XX):XXXX–XXXX. 
% 
%

%% Choose angle-dependent absorption or random incidence
isAngleDependent = true; 

%% Prepare spherical sampling grid
[X, Y, Z] = MakeSphericalGrid(1000);
s_grid.X = X;
s_grid.Y = Y;
s_grid.Z = Z;

%% Example configurations

% L_v = Room dimensions [X-axis (r1), Y-axis (r2), Z-axis (r3)]
% Z0 = Normalized wall impedance [x+, y+, z+, x-, y-, z-]

%% Figure 2a
L_v = [15, 15, 15]; 
Z0 = [10, 10, 10, 10, 10, 10]; 
RT60 = ISM_Formula3D(L_v, Z0, s_grid, isAngleDependent);
PlotDirectionalRT60(s_grid, RT60);

%% Figure 2b
L_v = [8, 8, 8];
Z0 = [20, 20, 20, 0.4, 5, 5];
RT60 = ISM_Formula3D(L_v, Z0, s_grid, isAngleDependent);
PlotDirectionalRT60(s_grid, RT60);

%% Figure 2c
L_v = [6, 7, 11];
Z0 = [20, 0.4, 20, 20, 72, 0.4];
RT60 = ISM_Formula3D(L_v, Z0, s_grid, isAngleDependent);
PlotDirectionalRT60(s_grid, RT60);

% % -----------------------------------------
%% Utility functions for the figure

function [X, Y, Z] = MakeSphericalGrid(grid_res)
    % Define spherical grid 

    az = (0:1/grid_res:(1-1/grid_res))' .* (2*pi);
    ele = (-0.5:2/grid_res:0.5-2/grid_res)' .* pi;

    [theta, phi] = meshgrid(az, ele);
    [X,Y,Z] = sph2cart(theta, phi, 1);
end

function PlotDirectionalRT60(s_grid, RT60)
    
    %% Draw RT60 values on the spherical grid
    figure
    surf(s_grid.X, s_grid.Y, s_grid.Z, RT60)

    %% Draw axis
    hold on
    r = 1.55;
    r2 = 1.76;

    plot3([-r r], [0, 0], [0 0], 'k', 'LineWidth', 1);
    plot3([0 0], [-r, r], [0 0], 'k', 'LineWidth', 1);
    plot3([0 0], [0, 0], [-r r], 'k', 'LineWidth', 1);
    text(-r2, 0, 0, strcat("$r_1$"), 'FontSize', 10, 'Interpreter', 'latex');
    text(0, -r2, 0, strcat("$r_2$"), 'FontSize', 10, 'Interpreter', 'latex');
    text(0, 0, r2, strcat("$r_3$"), 'FontSize', 10, 'Interpreter', 'latex');

    %% Figure parameters
    r = 1;
    xlim([-r, r]);
    ylim([-r, r]);
    zlim([-r, r]);
    axis equal
    shading flat 
    hold off
    grid off
    axis off
    box off

    h = colorbar('south', 'AxisLocation', 'out');
    h.Label.Interpreter = 'latex';
    h.Label.String = '$\mathrm{RT}_{60}$';
    set(gca,'ColorScale','log')
    set(gca,'DataAspectRatio',[1 1 1])
    set(gca,'Projection', 'perspective');

    MakeHSVColormap();
end

function MakeHSVColormap()
    
    %% Define color map used in the article

    hsv1 = [222/360, 1, 0.75; 222/360, 0.65, 1; 0, 0, 1; 0, 0.65, 1];
    hsv2 = [222/360, 0.65, 1; 222/360, 0, 1; 0, 0.65, 1; 0, 1, 1];
    n = [60, 25, 25, 60];

    H = [];
    S = [];
    V = [];

    for i = 1:size(hsv1, 1)
        H = [H, linspace(hsv1(i, 1), hsv2(i, 1), n(i))];
        S = [S, linspace(hsv1(i, 2), hsv2(i, 2), n(i))];
        V = [V, linspace(hsv1(i, 3), hsv2(i, 3), n(i))];
    end

    colormap( hsv2rgb([H(:), S(:), V(:)]) );
end

