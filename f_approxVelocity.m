function [vel,time]=f_approxVelocity(Xmid, Ymid, SF)
%Calculates velocity per track

%Xmid=X_coord from SACR marker
%Ymid=Y_coord from SACR marker

start=(1);
stop=length(Xmid);

%make sure there are no NaN
%start and stop are the same for X and Y 
Xstop=Xmid(stop); 
while isnan(Xstop) ;
    stop=stop-1;
    Xstop=Xmid(stop);
end

Xstart=Xmid(start);
while isnan(Xstart);
    start=start+1;
    Xstart=Xmid(start);
end 
    
%calculate the spatial difference
Xdiff=abs(Xstop-Xstart);
Ydiff=abs(Ymid(stop)-Ymid(start));
diff_mm=sqrt(Xdiff^2+Ydiff^2);
diff_mm=diff_mm*100;
time=(abs(stop-start))/SF;

%velocity [mm/s]
vel=diff_mm/time;