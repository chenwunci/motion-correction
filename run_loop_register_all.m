% This code is used for data processing in the manuscript titled "Discrete Photoentrainment of 
% the Mammalian Central Clock Regulated by a Bi-Stable Dynamic Network in the Suprachiasmatic Nucleus."

%-------------------------------------------------------------------------
% Kai-Chun Jhan - ver 1.0 2024-06-21
% Data Analysis and Interpretation Laboratory, NTHU
% Photoreceptor and Circadian clock Laboratory, NTU

%-------------------------------------------------------------------------
%%
function run_loop_register_all(enhance_contrast)

AA=dir('.\img');
folder_num=length(AA)-3+1;
currentFolder = pwd;
for imf=3:length(AA)%3:folder_num

    subf=(strcat('.\img\',AA(imf).name))
    copyfile('transfer_stack_tif.m',subf);
    copyfile('run_loop_register.m',subf);
    copyfile('apply_raw.m',subf);
    cd(subf);
    [z_slice_num, time_num] = transfer_stack_tif;
    run_loop_register(z_slice_num, time_num,enhance_contrast);
    apply_raw;
    cd(currentFolder);


end
    
end
% end