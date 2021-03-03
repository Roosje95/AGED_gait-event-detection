%% Main_Algorithms
% Main sheet for generating result matrices for all algorithms

% Codes connected to Visscher & Sansgiri et al. "Towards validation and 
% standardization of automatic gait event identification algorithms for use
% in paediatric pathological populations".
% Current version is with hallux instead of toemarker - if you want to
% adapt replace LHLX/RHLX with LTOE/RTOE.

% Needed to run: 
% 1. btk installed [http://biomechanical-toolkit.github.io/] 
% 2. Trails_info.xlsx 
% 3. Matlab functions

% Outcomes: after running the code table1 reports the frame on which event
% is detected per method, if you want ms instead of frame

% Date: 4.11.2020
% Sailee Sansgiri & Rosa Visscher
% contact: bt@ethz.ch 

close all;
clc;

%% Inital set-up

% TestDIR=uigetdir([], ‘Select the folder with the test data’); test out to
% automatic select the folder
btkFolder     = 'P:\Projects\NCM_CP\read_only\Codes\Codes_Basics\Codes_UKBB\btk';%add location were btk folder from biomechanical toolkit is saved
addpath(btkFolder);
addpath('P:\Projects\NCM_CP\project_only\NCM_CP_GaitEventDetection\Manuscript\G&P_v1\GitLab_Codes'); %add path to where zyou saved our matlab functions
addpath('P:\Projects\NCM_CP\project_only\NCM_CP_GaitEventDetection\Manuscript\G&P_v1\GitLab_Codes\example_c3d'); %add path towards c3d files

table1=readtable('Trails_info.xlsx');% replace Trails_Info.xlsx bz complete path of teh file isnt on the matlab path already

cd P:\Projects\NCM_CP\project_only\NCM_CP_GaitEventDetection\Manuscript\G&P_v1\GitLab_Codes\example_c3d %go to folder in which c3d files are saved

%% Initialize variables
c3dlist=table1{:,1}; % names of c3d files which you would like to evaluate
FP = table1{:,2}; % numbers refering to which force platform was hit during each trail (c3d file)
Side = table1{:,3}; % indicates is this trail is with force plate hit on left or right side

% for-loop to perform calculations for all c3d files
for i=1:length(c3dlist)
    
    c3dfile = c3dlist(i);
    btkData=btkReadAcquisition(c3dfile{1,1});
    btkClearEvents(btkData);
    metadata=btkGetMetaData(btkData);
    ff=btkGetFirstFrame(btkData);
    Markers = btkGetMarkers(btkData);
    angles=btkGetAngles(btkData);
    f = btkGetPointFrequency(btkData);
    freq(i,1)=f;
    
    n = btkGetPointFrameNumber(btkData);
    FPnumber=FP(i);
    
    %% Determine FP events
    temp = btkGetGroundReactionWrenches(btkData);
    for t = 1:length(temp(FPnumber).F(:,3))
        if temp(FPnumber).F(t,3) < 20 % 15 N threshold on Z axis (vertical)
            temp(FPnumber).F(t,:) = 0;
        end
    end
    Forces = interpft(temp(FPnumber).F(:,3),n); % Z axis (vertical)
    mFS = NaN;
    if min(find(Forces>1e-4))
        mFS = min(find(Forces>1e-4));
    end
    if ~isnan(mFS)
        mFO = min(find(Forces(mFS+20:end)<1e-4)+mFS+20-1);
    else
        mFO = NaN;
    end
    mFO_ms=(mFO/f)*1000    ;
    mFS_ms=(mFS/f)*1000    ;
    
    
    %% Define Markers
    
    if (strcmp(Side{i,1},'Left') ||strcmp(Side{i,1},'left'))
        heelMarkerName = 'LHEE';
        toeMarkerName = 'LHLX';
    else
        heelMarkerName = 'RHEE';
        toeMarkerName = 'RHLX';
    end
    
    % Zeni Markers
    sacralMarkerName='SACR';
    LPSI='LPSI';
    RPSI='RPSI';
    LASI='LASI';
    RASI='RASI';
    
    %% Correct for Walking Direction
    SACR = Markers.SACR;
    
    % delete zeros at the beginning or end of an trial
    
    dir_i = abs(SACR(end, 1) - SACR(1, 1));
    dir_j = abs(SACR(end, 2) - SACR(1, 2));
    
    walkdir = 1;  % x is walkdir
    
    if (dir_i < dir_j)
        walkdir = 2;  % y is walkdir
    end
    
    % pos. or neg. direktion on axis
    sgn = sign(SACR(end, walkdir) - SACR(1, walkdir));
    walkdir = walkdir * sgn;
    [Markers_Corrected]=f_rotCoordinateSystem(Markers, walkdir, 1);
    gaitAxis=1;
    verticalAxis=3;
    
    %% Filtering Markers and preprocessing
    [B,A] = butter(4,6/(f/2),'low');
    velfootcentre=[];
    Hvelocity_sagittal= [];
    Fvelocity_sagittal= [];
    Hvelocity_horizontal=[];
    Fvelocity_horizontal=[];
    Hvelocity_vertical=[];
    Fvelocity_vertical=[];
    filtheelmarker = [];
    Hacc_sag=[];
    Hacc_hor=[];
    Hacc_ver=[];
    Facc_sag=[];
    Facc_hor=[];
    Facc_ver=[];
    filttoemarker = [];
    filtsacrmarker=[];
    filtRPSI=[];
    filtLPSI=[];
    filtRASI=[];
    filtLASI=[];
    filtheelmarker(:,:,1) = filtfilt(B, A, Markers_Corrected.(heelMarkerName));
    filttoemarker(:,:,1) = filtfilt(B, A, Markers_Corrected.(toeMarkerName));
    filtsacrmarker(:,:,1) = filtfilt(B, A, Markers_Corrected.(sacralMarkerName));
    filtLPSI(:,:,1) = filtfilt(B, A, Markers_Corrected.(LPSI));
    filtRPSI(:,:,1) = filtfilt(B, A, Markers_Corrected.(RPSI));
    filtLASI(:,:,1) = filtfilt(B, A, Markers_Corrected.(LASI));
    filtRASI(:,:,1) = filtfilt(B, A, Markers_Corrected.(RASI));
    
    ysacr=filtsacrmarker(:,gaitAxis,:);
    zsacr=filtsacrmarker(:,verticalAxis,:);
    yheel=filtheelmarker(:,gaitAxis,:);
    ytoe=filttoemarker(:,gaitAxis,:);
    
    %Determine approximate walking speed
    [vel,time]=f_approxVelocity(ysacr,zsacr,f);
    vel2=vel/100;
    
    %% Kinematics
    
    %Calculate velocity of markers
    for t = 1:n-1
        Hvelocity_sagittal(t) = sqrt((filtheelmarker(t+1,gaitAxis)- filtheelmarker(t,gaitAxis))^2+(filtheelmarker(t+1,verticalAxis)- filtheelmarker(t,verticalAxis))^2)/(1/f);
        Fvelocity_sagittal(t) = sqrt((filttoemarker(t+1,gaitAxis)- filttoemarker(t,gaitAxis)).^2+(filttoemarker(t+1,verticalAxis)- filttoemarker(t,verticalAxis)).^2)/(1/f); % mm/s
        Hvelocity_horizontal(t)=(filtheelmarker(t+1,gaitAxis)-filtheelmarker(t,gaitAxis))/(1/f);
        Fvelocity_horizontal(t)=(filttoemarker(t+1,gaitAxis)-filttoemarker(t,gaitAxis))/(1/f);
        Hvelocity_vertical(t)=(filtheelmarker(t+1,verticalAxis)-filtheelmarker(t,verticalAxis))/(1/f);
        Fvelocity_vertical(t)=(filttoemarker(t+1,verticalAxis)-filttoemarker(t,verticalAxis))/(1/f);
    end
    
    %Calculate accelerations
    %
    for j = 1:size(Hvelocity_sagittal,2)-1
        Hacc_sag(j)=(Hvelocity_sagittal(j+1)- Hvelocity_sagittal(j))/(1/f);
        Hacc_hor(j)=(Hvelocity_horizontal(j+1)- Hvelocity_horizontal(j))/(1/f);
        Hacc_ver(j)=(Hvelocity_vertical(j+1)- Hvelocity_vertical(j))/(1/f);
    end
    for j = 1:size(Fvelocity_sagittal,2)-1
        Facc_sag(j)=(Fvelocity_sagittal(j+1)- Fvelocity_sagittal(j))/(1/f);
        Facc_hor(j)=(Fvelocity_horizontal(j+1)- Fvelocity_horizontal(j))/(1/f);
        Facc_ver(j)=(Fvelocity_vertical(j+1)- Fvelocity_vertical(j))/(1/f);
    end
    
    
    %% Kinematic Algorithm_Zeni
    [eFO_zeni_frame,eFS_zeni_frame,eFO_zeni_ms,eFS_zeni_ms]=f_zeni_event(f,yheel,ytoe,ysacr,mFO,mFS);
    
%     %% Kinematic Algorithm_Hsue
%     [eFO_Hsue_frame,eFS_Hsue_frame,eFO_Hsue_ms,eFS_Hsue_ms]=f_hsue_event(Hacc_hor, Facc_hor,mFO,mFS,f);
%     
    %% Kinematic Algorithm_Ghoussayni
    vThreshold=500;
    FS=[];
    FO=[];
    [FS_G,FO_G] = f_Ghoussayni_500(filtheelmarker,filttoemarker,gaitAxis,verticalAxis,n,f);
    [eFO_G_frame,eFS_G_frame,eFO_G_ms,eFS_G_ms]=f_mG_event(FO_G, FS_G,mFO,mFS,f);
    
    %% Kinematic Algorithm_ModifiedGhoussayni
    [FS_mG,FO_mG]=f_Ghoussayni_variablethreshold(filtheelmarker,filttoemarker,gaitAxis,verticalAxis,n,f,vel2);
    [eFO_mG_frame,eFS_mG_frame,eFO_mG_ms,eFS_mG_ms]=f_mG_event(FO_mG, FS_mG,mFO,mFS,f);
    
    %% Kinematic algorithm_Desailly
    [B,A] = butter(4,(7/(f/2)));
    filttoemarker_d = filtfilt(B, A, Markers_Corrected.(toeMarkerName));
    filtheelmarker_d = filtfilt(B, A, Markers_Corrected.(heelMarkerName));
    fhm2 = filttoemarker_d(1:end,gaitAxis);
    fhm=filtheelmarker_d(1:end,gaitAxis);
    [z,p,k] = butter(4,0.5/(f/2),'high');
    [sos,g] = zp2sos(z,p,k);
    L_toe_high  = filtfilt(sos,g,fhm2);
    L_heel_high=filtfilt(sos,g,fhm);
    
    [location_d_TO,index_d_TO]=findpeaks(-L_toe_high);
    [location_d_FS,index_d_FS]=findpeaks(L_heel_high);
    
    [eFS_D_frame,eFS_D_ms]= f_desailly_event(L_heel_high,mFS,f,location_d_FS,index_d_FS );
    [eFO_D_frame,eFO_D_ms]= f_desailly_event(L_heel_high,mFO,f,location_d_TO,index_d_TO );
    
    %% Kinematic algorithm_OConnor
    zheel= filtheelmarker_d(:,verticalAxis);
    ztoe=filttoemarker_d(:,verticalAxis);
    zCoordfootcentre = 1/2 * (zheel + ztoe);
    for j=1:length(zheel)
        footcentre(j)=(zheel(j)+ztoe(j))/2;
    end
    p=1;
    for j=1:length(ztoe)-1
        velfootcentre(p)=(footcentre(j+1)-footcentre(j))/(1/f);
        p=p+1;
    end
    
    [eFO_oconnor_frame,eFS_oconnor_frame,eFO_oconnor_ms, eFS_oconnor_ms]=f_oConnor_event(f,zheel,velfootcentre,mFS,mFO);
    
%     %% Kinematic algorithm_Hreljac
%     threshold=0.3 * max(Facc_hor);
%     [vFS_hreljac,FSindex_hreljac]=findpeaks(Hacc_ver);
%     [vFO_hreljac,FOindex_hreljac]=findpeaks(Facc_hor);
%         
%     [eFO_hreljac_frame,eFS_hreljac_frame,eFO_hreljac_ms,eFS_hreljac_ms]=f_hreljac_event(Hacc_hor, Facc_hor,Hacc_ver, Facc_ver,mFO,mFS,f);  
%     
    %% collect outcomes in table
    table1.FP_FS(i)= mFS;
    table1.Zeni_FS(i)= eFS_zeni_frame;
    table1.Ghoussayni_FS(i)= eFS_G_frame;
    table1.mGhoussayni_FS(i)= eFS_mG_frame;
    table1.Desailly_FS(i)= eFS_D_frame;
    table1.Oconnor_FS(i)= eFS_oconnor_frame;    
    table1.FP_FO(i)= mFO;
    table1.Zeni_FO(i)= eFO_zeni_frame;
    table1.Ghoussayni_FO(i)= eFO_G_frame;
    table1.mGhoussayni_FO(i)= eFO_mG_frame;
    table1.Desailly_FO(i)= eFO_D_frame;
    table1.Oconnor_FO(i)= eFO_oconnor_frame;
        
end %FOR-loop c3d files

disp(table1)% show results in command Window

