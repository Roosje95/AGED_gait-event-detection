
function [eFO_oconnor_frame,eFS_oconnor_frame,eFO_oconnor_ms, eFS_oconnor_ms]=f_oConnor_event(f,zheel, velfootcentre,mFS,mFO)

                mpd = 0.08*f;
                mpd2=0.8 *f;
                [value_fo,FOindex_oconnor]=findpeaks(velfootcentre,'minpeakdistance', mpd2);
                [value_fs,FSindex_oconnor]=findpeaks(-velfootcentre, 'minpeakdistance', mpd);
                
                thres=min(zheel) + 0.35 * (max(zheel) - min(zheel)); %threshold for height for zheel
                
                for r=1:length(FSindex_oconnor)
                    in=FSindex_oconnor(r);
                    if(zheel(in)>thres)
                        value_fs(r)=0;
                        FSindex_oconnor(r)=0;
                    end
                end

                        
                
                twindow = 80; % two consecutive events must be at least distant of 30 frames
                p_oconnor=0;
                p2_oconnor=0;
                diffFO_oconnor=[];
                diffFS_oconnor=[];
                FOval_oconnor=[];
                FSval_oconnor=[];
 
 
                if(isnan(mFO))
                    %do nothing;
                else
                for i= 1:length(FOindex_oconnor)
                d=abs(FOindex_oconnor(i)-mFO);
                if(d<twindow)
                    p_oconnor=p_oconnor+1;
                    FOval_oconnor(p_oconnor)=FOindex_oconnor(i);
                    
                    
                    diffFO_oconnor(p_oconnor)=d;
                end
                end
                end
                
                if(isnan(mFS))
                %DO NOTHING;
                else
                    for i= 1:length(FSindex_oconnor)
                    d=abs(FSindex_oconnor(i)-mFS);
                    
                    if(d<twindow)
                    p2_oconnor=p2_oconnor+1;
                    FSval_oconnor(p2_oconnor)=FSindex_oconnor(i);
                    diffFS_oconnor(p2_oconnor)=d;
                    end
                    end
                end
                d=0;
                if(isnan(mFO))
                    %DO NOTHING;
                else   
                [value,index]=min(diffFO_oconnor);
                eFO_oconnor=FOval_oconnor(index);
                end
                
                if(isnan(mFS))
                %DO NOTHING;
                else
                [value,index]=min(diffFS_oconnor);
                eFS_oconnor=FSval_oconnor(index);
                end

                if(isempty(eFS_oconnor)==1)
                    eFS_oconnor=0;
                end
                if(isempty(eFO_oconnor)==1)
                    eFO_oconnor=0;
                end
                eFO_oconnor_frame=eFO_oconnor;
                 eFS_oconnor_frame=eFS_oconnor;
                 eFO_oconnor_ms=(eFO_oconnor/f)*1000    ;
                 eFS_oconnor_ms=(eFS_oconnor/f)*1000    ;
                
 