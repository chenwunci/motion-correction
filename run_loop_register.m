function run_loop_register_simple(z_slice_num, time_num,enhance_contrast)
A = dir('.\img_crop\');

if ~exist(dir('.\singleodor_crop\'))
    mkdir(strcat('.\singleodor_crop\'));
end

fname = strcat('.\img_crop\',A(3).name);
save_fname = strsplit(fname,"\");
save_fname = strsplit(cell2mat(save_fname(end)),".");
save_fname = cell2mat(save_fname(1))+"_registered.tif"
[optimizer, metric] = imregconfig('monomodal');
% time_num
for slicenum=1:z_slice_num;
    %     close all
    load(strcat('total_img_',num2str(slicenum),'.mat'));
    Iref = total_img(:,:,1);
    Iref_hist = histeq(Iref);
    x_loc = [];
    y_loc = [];

    fTIF = Fast_BigTiff_Write(strcat('.\singleodor_crop\',save_fname));
    fTIF.WriteIMG(uint16(Iref)');
    for f=2:time_num;
        [slicenum f]
%     for f=2:10;
        Imov = total_img(:,:,f);
        if enhance_contrast
            Imov_hist = histeq(Imov);
            tform=imregtform(Imov_hist, Iref_hist, 'translation', optimizer, metric);
        else
            tform=imregtform(Imov, Iref, 'translation', optimizer, metric);
        end
        [x,y] = transformPointsForward(tform, 0,0);
        disp(strcat("frame = ",num2str(f)," x loc = ",num2str(x)," y loc = ",num2str(y)))

        centerOutput = affineOutputView(size(Iref),tform,'BoundsStyle','centerOutput');
        
        x_loc = [x_loc x];
        y_loc = [y_loc y];
        if ((abs(x)<30) & (abs(y)<30))
            centerOutput = affineOutputView(size(Iref),tform,'BoundsStyle','centerOutput');
            movingRegistered = imwarp(Imov,tform,'OutputView',centerOutput);

        else
            movingRegistered = Imov;
        end
        fTIF.WriteIMG(uint16(movingRegistered)');
        save(strcat('movingRegistered_',num2str(slicenum),'_',num2str(f),'.mat'),'movingRegistered','tform');
    end
    fTIF.close;
    save(strcat('trace_',num2str(slicenum),'.mat'),"x_loc", "y_loc");
end
