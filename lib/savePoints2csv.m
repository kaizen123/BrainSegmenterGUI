function savePoints2csv(csvFNin,x2p5int2,x2p5Width)
%% Last Modified by LM, 10Jun2015

global bigWidth bigHeight
        
        flipP = questdlg('Flip tracer points?', 'Flip','Yes','No','No');
        switch flipP
        case 'Yes'
            x2p5int2(:,1) = x2p5Width - x2p5int2(:,1);
            disp('Points flipped before saving to csv.');
        end
        
        csvFN = [csvFNin '_xy2p5xRedIn.csv'];
        %csvwrite(csvFN,x2p5int2);
        x = x2p5int2(:,1);
        y = x2p5int2(:,2);
        T = table(x,y);
        writetable(T,csvFN);
        var11 = length(x2p5int2);
        var11 = var11 - 1; %x y 
        disp(['Total of ' num2str(var11) ' Red positive cells saved to CSV file.']);        

        x2p5mm = double(x2p5int2);
        x2p5mm = x2p5mm*0.0036;  %mm/pix
        %x2p5mm_int = uint16(x2p5mm);    
        csvFN = [csvFNin '_xy2p5xRed_mmIn.csv'];
        x = x2p5mm(:,1);
        y = x2p5mm(:,2);
        T = table(x,y);
        writetable(T,csvFN);
        %csvwrite(csvFN,x2p5mm);
