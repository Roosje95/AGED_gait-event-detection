function [eFO_zeni_frame,eFS_zeni_frame,eFO_zeni_ms,eFS_zeni_ms]=f_zeni_event(f,yheel,ytoe,ysacr,mFO,mFS)

 twindow = 30; %window of 30 frames
 
 diffFS_zeni=[];
 FOval_zeni=[];
 FSval_zeni=[];
 diffFO_zeni=[];
 p_zeni=0;
 p2_zeni=0;

                
                %Determine FS and FO using Zeni's Algorithm
                 
     
                tFS = yheel-ysacr;
                tFO = ytoe-ysacr;
                [vFS_zeni,FSindex_zeni] = findpeaks(tFS);
                [vFO_zeni,FOindex_zeni] = findpeaks(-tFO);
                
                    if(isnan(mFO))
                    %do nothing;
                    else
                        for i= 1:length(FOindex_zeni)
                        d=abs(FOindex_zeni(i)-mFO);
                            if(d<twindow)
                            p_zeni=p_zeni+1;
                            FOval_zeni(p_zeni)=FOindex_zeni(i);
                            diffFO_zeni(p_zeni)=d;
                            end
                        end
                    end

                    if(isnan(mFS))
                    %DO NOTHING;
                    else
                        for i= 1:length(FSindex_zeni)
                        d=abs(FSindex_zeni(i)-mFS);
                            if(d<twindow)
                            p2_zeni=p2_zeni+1;
                            FSval_zeni(p2_zeni)=FSindex_zeni(i);
                            diffFS_zeni(p2_zeni)=d;
                            end
                        end
                    end
                    d=0;
                    if(isnan(mFO))
                    %DO NOTHING;
                    else   
                    [value,index]=min(diffFO_zeni);
                    eFO_zeni=FOval_zeni(index);

                    end
                    if(isnan(mFS))
                        %DO NOTHING
                    else
                        [value,index]=min(diffFS_zeni);
                        eFS_zeni=FSval_zeni(index);
                        
                    end
                    eFO_zeni_frame=(eFO_zeni);
                    eFS_zeni_frame=(eFS_zeni);
                    
                    eFO_zeni_ms=(eFO_zeni/f)*1000;
                    eFS_zeni_ms=(eFS_zeni/f)*1000;
end