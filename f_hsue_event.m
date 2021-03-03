function [eFO_Hsue_frame,eFS_Hsue_frame,eFO_Hsue_ms,eFS_Hsue_ms]=f_hsue_event(Hacc_hor, Facc_hor,mFO,mFS,f)

%Determine FS and FO using Hsue's algorithm
                [vFS_Hsue,FSindex_hsue]=findpeaks(-Hacc_hor);
                [vFO_Hsue,FOindex_hsue]=findpeaks(Facc_hor);
                
                

                twindow = 100; % two consecutive events must be at least distant of 30 frames
                p_hsue=0;
                p2_hsue=0;
                diffFO_hsue=[];
                diffFS_hsue=[];
                FOval_hsue=[];
                FSval_hsue=[];


                if(isnan(mFO))
                    %do nothing;
                else
                for i= 1:length(FOindex_hsue)
                d=abs(FOindex_hsue(i)-mFO);
                if(d<twindow)
                    p_hsue=p_hsue+1;
                    FOval_hsue(p_hsue)=FOindex_hsue(i);
                    diffFO_hsue(p_hsue)=d;
                end
                end
                end
                
                if(isnan(mFS))
                %DO NOTHING;
                else
                    for i= 1:length(FSindex_hsue)
                    d=abs(FSindex_hsue(i)-mFS);
                    
                    if(d<twindow)
                    p2_hsue=p2_hsue+1;
                    FSval_hsue(p2_hsue)=FSindex_hsue(i);
                    diffFS_hsue(p2_hsue)=d;
                    end
                    end
                end
                d=0;
                if(isnan(mFO))
                    %DO NOTHING;
                else   
                [value,index]=min(diffFO_hsue);
                eFO_hsue=FOval_hsue(index);
                end
                
                if(isnan(mFS))
                %DO NOTHING;
                else
                [value,index]=min(diffFS_hsue);
                eFS_hsue=FSval_hsue(index);
                end
                
                eFS_Hsue_frame=eFS_hsue;
                eFO_Hsue_frame=eFO_hsue;
                
                eFS_Hsue_ms=(eFS_hsue/f)*1000;
                eFO_Hsue_ms=(eFO_hsue/f)*1000;
end