% This code is used for data processing in the manuscript titled "Discrete Photoentrainment of 
% the Mammalian Central Clock Regulated by a Bi-Stable Dynamic Network in the Suprachiasmatic Nucleus."

%-------------------------------------------------------------------------
% Kai-Chun Jhan - ver 1.0 2024-06-21
% Data Analysis and Interpretation Laboratory, NTHU
% Photoreceptor and Circadian clock Laboratory, NTU

%-------------------------------------------------------------------------
%%
A = dir('.\img_raw\');
stack_time = false;
z_slice_num = length(A)-3+1;

if ~exist(strcat('.\singletrial_raw\'),"dir")
    mkdir(strcat('.\singletrial_raw\'));
end


for zz = 1:z_slice_num %1~3ok
    fname = strcat('.\img_raw\',A(zz+2).name);
    save_fname = strsplit(fname,"\");
    save_fname = strsplit(cell2mat(save_fname(end)),".");
    save_fname = cell2mat(save_fname(1))+"_registered.tif"
    
    info = imfinfo(fname);
    img_h=info.Height;% break to line 15 , check first
    img_w=info.Width;% break to line 15 , check first

    total_img = tiffreadVolume(fullfile('.\img_raw\',A(zz+2).name));
    time_num = size(total_img,3);
    I_ref = total_img(:,:,1);
    fTIF = Fast_BigTiff_Write(strcat('.\singletrial_raw\',save_fname));
    fTIF.WriteIMG(uint16(I_ref)');
    for t_num = 2:time_num
        %fname = strcat('.\img\',A(t_num+2).name);
        load(".\movingRegistered_1_"+num2str(t_num)+".mat");
        I=total_img(:,:,t_num);
        centerOutput = affineOutputView(size(I),tform,'BoundsStyle','centerOutput');
        movingRegistered_trial= imwarp(I,tform,'OutputView',centerOutput);
        fTIF.WriteIMG(uint16(movingRegistered_trial)');
    end
    fTIF.close;
end
