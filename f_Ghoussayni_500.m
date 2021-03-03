function [FS,FO] = f_Ghoussayni_500(Hmarkers,Fmarkers,gaitAxis,verticalAxis,n,f)

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
% Calculate the 2D velocity of the markers barycenter in the plane 
% containing gait (V1) and vertical (V2) axes (ONLY FOR CASE 3)
% -------------------------------------------------------------------------
for t = 1:n
    % Hindfoot markers barycenter
    Hbarycenter(t,1) = sum(Hmarkers(t,1,:))/size(Hmarkers,3);
    Hbarycenter(t,2) = sum(Hmarkers(t,2,:))/size(Hmarkers,3);
    Hbarycenter(t,3) = sum(Hmarkers(t,3,:))/size(Hmarkers,3);
    % Forefoot markers barycenter
    Fbarycenter(t,1) = sum(Fmarkers(t,1,:))/size(Fmarkers,3);
    Fbarycenter(t,2) = sum(Fmarkers(t,2,:))/size(Fmarkers,3);
    Fbarycenter(t,3) = sum(Fmarkers(t,3,:))/size(Fmarkers,3);
end
for t = 1:n-1
    % Hindfoot barycenter velocity
    HBvelocity(t) = sqrt((Hbarycenter(t+1,gaitAxis)- ...
        Hbarycenter(t,gaitAxis))^2+ ...
        (Hbarycenter(t+1,verticalAxis)- ...
        Hbarycenter(t,verticalAxis))^2)/ ...
        (1/f);
    % Forefoot barycenter velocity
    FBvelocity(t) = sqrt((Fbarycenter(t+1,gaitAxis)- ...
        Fbarycenter(t,gaitAxis))^2+ ...
        (Fbarycenter(t+1,verticalAxis)- ...
        Fbarycenter(t,verticalAxis))^2)/ ...
        (1/f);
end

% -------------------------------------------------------------------------
% Velocity threshold (empirically set)
% 50 mm/s in the original article for barefoot gait
% 500 mm/s in Bruening et al., 2014
% -------------------------------------------------------------------------
vThreshold = 500;
% -------------------------------------------------------------------------
% Detect events using the velocity threshold
% CASE #1: The event is defined when a first marker has a velocity under
%          threshold for FS, the last marker over threshold for FO
% -------------------------------------------------------------------------
twindow = fix(30/150*f); % two consecutive events must be at least distant of 30 frame (at 150 Hz)
for t = 1:n-1
    % Foot strike defined using heel marker
    if isempty(FS) && isempty(FO)
        temp = [];
        for i = 1:size(Hvelocity,2)
            if Hvelocity(t,i) <= vThreshold
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
            if Hvelocity(t,i) <= vThreshold && ...
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
        % Do nothing: wait for a first FS (assume that we detect first a FS)
    elseif ~isempty(FS) && isempty(FO)
        temp = [];
        for i = 1:size(Fvelocity,2)
            if Fvelocity(t,i) >= vThreshold && ...
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
            if Fvelocity(t,i) >= vThreshold && ...
               t >= FS(end)+twindow
                temp = t;
            end
        end
        if ~isempty(temp)
            FO = [FO temp];
        end
    elseif ~isempty(FS) && ~isempty(FO) && ...
            length(FO) == length(FS)
        % Do nothing: wait for the nest FS (assume that we detect first a FS)
    end
end