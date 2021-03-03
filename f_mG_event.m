function [eFO_mG_frame,eFS_mG_frame,eFO_mG_ms,eFS_mG_ms]=f_mG_event(FO_mG, FS_mG,mFO,mFS,f)

twindow = 30; % two consecutive events must be at least distant of 30 frames
                p_mG=0;
                p2_mG=0;
                diffFO_mG=[];
                diffFS_mG=[];
                FOval_mG=[];
                FSval_mG=[];
 
 
                if(isnan(mFO))
                    %do nothinmG;
                else
                for i= 1:length(FO_mG)
                d=abs(FO_mG(i)-mFO);
                if(d<twindow)
                    p_mG=p_mG+1;
                    FOval_mG(p_mG)=FO_mG(i);
                    diffFO_mG(p_mG)=d;
                end
                end
                end
                
                if(isnan(mFS))
                %DO NOTHINmG;
                else
                    for i= 1:length(FS_mG)
                    d=abs(FS_mG(i)-mFS);
                    
                    if(d<twindow)
                    p2_mG=p2_mG+1;
                    FSval_mG(p2_mG)=FS_mG(i);
                    diffFS_mG(p2_mG)=d;
                    end
                    end
                end
                d=0;
                if(isnan(mFO))
                    %DO NOTHINmG;
                else   
                [value,index]=min(diffFO_mG);
                eFO_mG=FOval_mG(index);
                end
                
                if(isnan(mFS))
                %DO NOTHINmG;
                else
                [value,index]=min(diffFS_mG);
                eFS_mG=FSval_mG(index);
                end
                eFS_mG_frame=eFS_mG;
                eFO_mG_frame=eFO_mG;
                
                eFS_mG_ms=(eFS_mG/f)*1000;
                eFO_mG_ms=(eFO_mG/f)*1000;
end

