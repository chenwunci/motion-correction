%align ACV

clear all
close all
clc
prompt = 'Which odor? ';
str = input(prompt,'s');



A = dir('.\img\');
load(strcat('tform_odor_',str,'.mat'));

%% exist dir

if ~exist(dir(strcat('.\img\',A(str2double(str)+2).name,'\alignodor_crop\')))
    mkdir(strcat('.\img\',A(str2double(str)+2).name,'\alignodor_crop\'))
end

if ~exist(dir(strcat('.\img\',A(str2double(str)+2).name,'\alignodor_raw\')))
    mkdir(strcat('.\img\',A(str2double(str)+2).name,'\alignodor_raw\'))
end


AA = dir(strcat('.\img\',A(str2double(str)+2).name,'\singleodor_crop\'));
fname = AA(3).name;
save_fname = strsplit(fname,".")
save_fname = cell2mat(save_fname(1))+"_aligned.tif";
%% apply crop
fTIF = Fast_BigTiff_Write(strcat('.\img\',A(str2double(str)+2).name,'\alignodor_crop\',save_fname));
total_img = tiffreadVolume(strcat('.\img\',A(str2double(str)+2).name,'\singleodor_crop\',AA(3).name));
t_num = size(total_img, 3);
for f=1:t_num
    I=total_img(:,:,f);
    centerOutput = affineOutputView(size(I),tform,'BoundsStyle','centerOutput');
    movingRegistered_odor= imwarp(I,tform,'OutputView',centerOutput);
%     x = int16(tform.T(3,1));
%     y = int16(tform.T(3,2));
%     movingRegistered_odor = I(-y+1:end,1:end-1);
%      
%      
%     movingRegistered_odor = [zeros(size(movingRegistered_odor,1),x) movingRegistered_odor];
%     movingRegistered_odor = [movingRegistered_odor;zeros(-y,size(movingRegistered_odor,2))];
    
    
    fTIF.WriteIMG(uint16(movingRegistered_odor)');
    
end
fTIF.close;

%% apply raw
AA = dir(strcat('.\img\',A(str2double(str)+2).name,'\singleodor_raw\'));

z_slice_num = length(AA)-3+1;
for zz = 1:z_slice_num %1~3ok
    fname = AA(zz+2).name;
    save_fname = strsplit(fname,".")
    save_fname = cell2mat(save_fname(1))+"_aligned.tif";
    
    fTIF = Fast_BigTiff_Write(strcat('.\img\',A(str2double(str)+2).name,'\alignodor_raw\',save_fname));
    total_img = tiffreadVolume(strcat('.\img\',A(str2double(str)+2).name,'\singleodor_raw\',AA(zz+2).name));
    t_num = size(total_img, 3);
    for f=1:t_num
        I=total_img(:,:,f);
        centerOutput = affineOutputView(size(I),tform,'BoundsStyle','centerOutput');
        movingRegistered_odor= imwarp(I,tform,'OutputView',centerOutput);
    %     x = int16(tform.T(3,1));
    %     y = int16(tform.T(3,2));
    %     movingRegistered_odor = I(-y+1:end,1:end-1);
    %      
    %      
    %     movingRegistered_odor = [zeros(size(movingRegistered_odor,1),x) movingRegistered_odor];
    %     movingRegistered_odor = [movingRegistered_odor;zeros(-y,size(movingRegistered_odor,2))];
        
        
        fTIF.WriteIMG(uint16(movingRegistered_odor)');
        
    end
    fTIF.close;
end