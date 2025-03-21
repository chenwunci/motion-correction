% This code is used for data processing in the manuscript titled "Discrete Photoentrainment of 
% the Mammalian Central Clock Regulated by a Bi-Stable Dynamic Network in the Suprachiasmatic Nucleus."

%-------------------------------------------------------------------------
% Kai-Chun Jhan - ver 1.0 2024-06-21
% Data Analysis and Interpretation Laboratory, NTHU
% Photoreceptor and Circadian clock Laboratory, NTU

%-------------------------------------------------------------------------
%%
%align ACV

clear all
close all
clc
prompt = 'Which trial? ';
str = input(prompt,'s');



A = dir('.\img\');
load(strcat('tform_trial_',str,'.mat'));

%% exist dir

if ~exist(strcat('.\img\',A(str2double(str)+2).name,'\aligntrial_auxiliary\'),"dir")
    mkdir(strcat('.\img\',A(str2double(str)+2).name,'\aligntrial_auxiliary\'))
end

if ~exist(strcat('.\img\',A(str2double(str)+2).name,'\aligntrial_raw\'),"dir")
    mkdir(strcat('.\img\',A(str2double(str)+2).name,'\aligntrial_raw\'))
end


AA = dir(strcat('.\img\',A(str2double(str)+2).name,'\singletrial_auxiliary\'));
fname = AA(3).name;
save_fname = strsplit(fname,".")
save_fname = cell2mat(save_fname(1))+"_aligned.tif";
%% apply auxiliary
fTIF = Fast_BigTiff_Write(strcat('.\img\',A(str2double(str)+2).name,'\aligntrial_auxiliary\',save_fname));
total_img = tiffreadVolume(strcat('.\img\',A(str2double(str)+2).name,'\singletrial_auxiliary\',AA(3).name));
t_num = size(total_img, 3);
for f=1:t_num
    I=total_img(:,:,f);
    centerOutput = affineOutputView(size(I),tform,'BoundsStyle','centerOutput');
    movingRegistered_trial= imwarp(I,tform,'OutputView',centerOutput);
%     x = int16(tform.T(3,1));
%     y = int16(tform.T(3,2));
%     movingRegistered_trial = I(-y+1:end,1:end-1);
%      
%      
%     movingRegistered_trial = [zeros(size(movingRegistered_trial,1),x) movingRegistered_trial];
%     movingRegistered_trial = [movingRegistered_trial;zeros(-y,size(movingRegistered_trial,2))];
    
    
    fTIF.WriteIMG(uint16(movingRegistered_trial)');
    
end
fTIF.close;

%% apply raw
AA = dir(strcat('.\img\',A(str2double(str)+2).name,'\singletrial_raw\'));

z_slice_num = length(AA)-3+1;
for zz = 1:z_slice_num %1~3ok
    fname = AA(zz+2).name;
    save_fname = strsplit(fname,".")
    save_fname = cell2mat(save_fname(1))+"_aligned.tif";
    
    fTIF = Fast_BigTiff_Write(strcat('.\img\',A(str2double(str)+2).name,'\aligntrial_raw\',save_fname));
    total_img = tiffreadVolume(strcat('.\img\',A(str2double(str)+2).name,'\singletrial_raw\',AA(zz+2).name));
    t_num = size(total_img, 3);
    for f=1:t_num
        I=total_img(:,:,f);
        centerOutput = affineOutputView(size(I),tform,'BoundsStyle','centerOutput');
        movingRegistered_trial= imwarp(I,tform,'OutputView',centerOutput);
    %     x = int16(tform.T(3,1));
    %     y = int16(tform.T(3,2));
    %     movingRegistered_trial = I(-y+1:end,1:end-1);
    %      
    %      
    %     movingRegistered_trial = [zeros(size(movingRegistered_trial,1),x) movingRegistered_trial];
    %     movingRegistered_trial = [movingRegistered_trial;zeros(-y,size(movingRegistered_trial,2))];
        
        
        fTIF.WriteIMG(uint16(movingRegistered_trial)');
        
    end
    fTIF.close;
end