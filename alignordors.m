clear all
close all

A = dir('.\img_odor\');
time_num = length(A)-3+1;
fname = strcat('.\img_odor\',A(3).name);
        info = imfinfo(fname);
z_slice_num=size(info,1); % break to line 15 , check first
img_h=info.Height;% break to line 15 , check first
img_w=info.Width;% break to line 15 , check first

for f=3:length(A) %1~3ok
    total_img = zeros(img_h,img_w,z_slice_num);
    for zz = 1:z_slice_num
        fname = strcat('.\img_odor\',A(f).name);
        info = imfinfo(fname);
        num_images = numel(info);
        
            KK = imread(fname, zz, 'Info', info);
            total_img(:,:,zz)=KK;
            % figure(1);imagesc(KK);pause(0.2)
            % ... Do somethig with image A ...
        
    end
%     for ff=1:time_num
%         figure(1),imagesc(reshape(total_img(:,:,ff),img_h,img_w));
%         axis equal;
%         title(num2str(ff));
%         pause(0.1);
%     end
    save(strcat('total_img_',num2str(f-2),'.mat'),'total_img');
end

proj_img=zeros(img_h,img_w,length(A)-2);
movingRegistered=zeros(img_h,img_w,length(A)-2);
for f=3:length(A)
    load(strcat('total_img_',num2str(f-2),'.mat'));
    proj_img(:,:,f-2)=sum(total_img,3);
end
Iref = proj_img(:,:,1);
movingRegistered(:,:,1)=Iref;
[optimizer, metric] = imregconfig('monomodal');


for f=2:size(proj_img,3)
    Imov = proj_img(:,:,f);
    
    tform=imregtform(Imov, Iref, 'translation', optimizer, metric);
%     movingRegistered = imwarp(Imov,tform,'OutputView',imref2d(size(Iref)));
%     imwrite(uint16(movingRegistered),strcat('result_',sprintf('%03d',f),'_registered_rigid.tif'));
   
    
    movingRegistered(:,:,f) = imwarp(Imov,tform,'OutputView',imref2d(size(Iref)));
    save(strcat('tform_odor_',num2str(f),'.mat'),'tform','movingRegistered');
end
writerObj = VideoWriter('AlignOrdors.avi');
writerObj.FrameRate=6;
writerObj.Quality=100;
open(writerObj);
fig=figure(1); hold on;
% figure,hold on
for f=1:size(proj_img,3)
    subplot(1,2,1),imagesc(proj_img(:,:,f));axis equal;colormap(gray(512));title(num2str(f));
    subplot(1,2,2),imagesc(movingRegistered(:,:,f));axis equal;colormap(gray(512));
    title(num2str(f));
    
    hold on;pause(1)
    frame = getframe(fig);
        writeVideo(writerObj,frame);
end
close(writerObj);