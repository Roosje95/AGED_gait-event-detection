%{ 
*********************************************************************************
Function "f_rotCoordinateSystem" linked to script "Auswertung_mitFormularen"
              run from "f_correctGaitDirection
                by Sebastian Krapf Feb. 2014
*********************************************************************************

Change coordinate system from vicon xyz to x'y'z'
Walking direktion gets positive x' (1)
Medio lateral = y'
Vertical stays z

Gets names for video (e.g. "AP anterior")

INPUT: xyz = Struct with markers or forces as output from c3d

OUTPUT: xyz = struct with markers/forces, where x = walking direction,
                                   y = medio-lateral, z = vertical
        videoFront/videoSagitt = New names for videos e.g. "Sagittal_right"
%}

function [xyz] = f_rotCoordinateSystem(xyz, walkdir, i)
 
    walksgn = 1;  % case x+
    saggdir = 2;
    saggsgn = 1;

    if (walkdir < -1)

        walkdir = 2;  % case y-
        walksgn = -1;
        saggdir = 1;
        saggsgn = 1;
        
        
    elseif (walkdir < 0)

        walkdir = 1;  %case x-
        walksgn = -1;
        saggdir = 2;
        saggsgn = -1;
        
    elseif (walkdir > 1)

        walkdir = 2;  % case y+
        walksgn = 1;
        saggdir = 1;  
        saggsgn = -1;
        
        
    end %IF (walkdir < -1)

    tm = fieldnames(xyz);                                                                                                                                        
    nm = length(tm);                                                                                                                                   

    for j = 1 : nm                                                                                                                                               
        xyz(i).(tm{j}) = [walksgn * xyz(i).(tm{j})(:, walkdir) ...
                          saggsgn * xyz(i).(tm{j})(:, saggdir) ...
                                    xyz(i).(tm{j})(:, 3)];                                                                                                 
    end %FOR j = 1 : nm                                                                                                                                                          

end  %FUNCTION f_rotCoordinateSystem    
