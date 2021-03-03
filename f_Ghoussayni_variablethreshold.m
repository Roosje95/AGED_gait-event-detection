function [FS,FO] = f_Ghoussayni_variablethreshold(Hmarkers,Fmarkers,gaitAxis,verticalAxis,n,f,vel2)

% -------------------------------------------------------------------------
% Initialisation
% -------------------------------------------------------------------------
FS = [];
FO = [];

% -------------------------------------------------------------------------
% Calculate the 2D velocity of the markers in the plane containing
% gait (V1) and vertical (V2) axes
% -------------------------------------------------------------------------
for t = 1:n-1
    % Hindfoot markers velocity
    for i = 1:size(Hmarkers,3)
        Hvelocity(t,i) = sqrt((Hmarkers(t+1,gaitAxis,i)- ...
            Hmarkers(t,gaitAxis,i))^2+ ...
            (Hmarkers(t+1,verticalAxis,i)- ...
            Hmarkers(t,verticalAxis,i))^2)/ ...
            (1/f);
    end
    % Forefoot markers velocity
    for i = 1:size(Fmarkers,3)
        Fvelocity(t,i) = sqrt((Fmarkers(t+1,gaitAxis,i)- ...
            Fmarkers(t,gaitAxis,i)).^2+ ...
            (Fmarkers(t+1,verticalAxis,i)- ...
            Fmarkers(t,verticalAxis,i)).^2)/ ...
            (1/f);
    end
end

% -------------------------------------------------------------------------
% Velocity threshold (empirically set)
% 50 mm/s in the original article for barefoot gait
% 500 mm/s in Bruening et al., 2014
% -------------------------------------------------------------------------

 vThreshold_FS = 0.78*vel2;
 vThreshold_FO=0.66*vel2;
%Calculate threshold, which is dependent on walking speed
% -------------------------------------------------------------------------
% Detect events using the velocity threshold
% CASE #1: The event is defined when a first marker has a velocity under
%          threshold for FS, the last marker over threshold for FO
% -------------------------------------------------------------------------
twindow = 15; % two consecutive events must be at least distant of 30 frame (at 150 Hz)
for t = 1:n-1
    % Foot strike defined using heel marker
    if isempty(FS) && isempty(FO)
        temp = [];
        for i = 1:size(Hvelocity,2)
            if Hvelocity(t,i) <= vThreshold_FS
                temp = t;
            end
        end
        if ~isempty(temp)
            FS = [FS temp];
        end
    elseif ~isempty(FS) && isempty(FO)
        % Do nothing: wait for a first FO (assume that we detect first a FS)
    elseif ~isempty(FS) && ~isempty(FO) && ...
            length(FS) > length(FO)
        % Do nothing: wait for the next FO (assume that we detect first a FS)
    elseif ~isempty(FS) && ~isempty(FO) && ...
            length(FS) == length(FO)
        temp = [];
        for i = 1:size(Hvelocity,2)
            if Hvelocity(t,i) <= vThreshold_FS && ...
               t >= FO(end)+twindow
                temp = t;
            end
        end
        if ~isempty(temp)
            FS = [FS temp];
        end
    end
    % Foot off defined using forefoot marker
    if isempty(FS) && isempty(FO)
        % Do nothing: wait for a first FS_ghoussayni (assume that we detect first a FS_ghoussayni)
    elseif ~isempty(FS) && isempty(FO)
        temp = [];
        for i = 1:size(Fvelocity,2)
            if Fvelocity(t,i) >= vThreshold_FO && ...
               t >= FS(end)+twindow
                temp = t;
            end
        end
        if ~isempty(temp)
            FO = [FO temp];
        end
    elseif ~isempty(FS) && ~isempty(FO) && ...
            length(FO) < length(FS)
        temp = [];
        for i = 1:size(Fvelocity,2)
            if Fvelocity(t,i) >= vThreshold_FO && ...
               t >= FS(end)+twindow
                temp = t;
            end
        end
        if ~isempty(temp)
            FO = [FO temp];
        end
    elseif ~isempty(FS) && ~isempty(FO) && ...
            length(FO) == length(FS)
        % Do nothing: wait for the nest FS_ghoussayni (assume that we detect first a FS_ghoussayni)
    end
end