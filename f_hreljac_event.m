function [eFO_hreljac_frame,eFS_hreljac_frame,eFO_hreljac_ms,eFS_hreljac_ms]=f_hreljac_event(Hacc_hor, Facc_hor,Hacc_ver, Facc_ver,mFO,mFS,f)

%Determine FS and FO using hreljac's algorithm
                [vFS_hreljac,FSindex_hreljac]=findpeaks(Hacc_ver);
                [vFO_hreljac,FOindex_hreljac]=findpeaks(Facc_hor);
                
                

                twindow = 100; % two consecutive events must be at least distant of 30 frames
                p_hreljac=0;
                p2_hreljac=0;
                diffFO_hreljac=[];
                diffFS_hreljac=[];
                FOval_hreljac=[];
                FSval_hreljac=[];


                if(isnan(mFO))
                    %do nothing;
                else
                for i= 1:length(FOindex_hreljac)
                d=abs(FOindex_hreljac(i)-mFO);
                if(d<twindow)
                    p_hreljac=p_hreljac+1;
                    FOval_hreljac(p_hreljac)=FOindex_hreljac(i);
                    diffFO_hreljac(p_hreljac)=d;
                end
                end
                end
                
                if(isnan(mFS))
                %DO NOTHING;
                else
                    for i= 1:length(FSindex_hreljac)
                    d=abs(FSindex_hreljac(i)-mFS);
                    
                    if(d<twindow)
                    p2_hreljac=p2_hreljac+1;
                    FSval_hreljac(p2_hreljac)=FSindex_hreljac(i);
                    diffFS_hreljac(p2_hreljac)=d;
                    end
                    end
                end
                d=0;
                if(isnan(mFO))
                    %DO NOTHING;
                else   
                [value,index]=min(diffFO_hreljac);
                eFO_hreljac=FOval_hreljac(index);
                end
                
                if(isnan(mFS))
                %DO NOTHING;
                else
                [value,index]=min(diffFS_hreljac);
                eFS_hreljac=FSval_hreljac(index);
                end
                
                eFS_hreljac_frame=eFS_hreljac;
                eFO_hreljac_frame=eFO_hreljac;
                
                eFS_hreljac_ms=(eFS_hreljac/f)*1000;
                eFO_hreljac_ms=(eFO_hreljac/f)*1000;
end