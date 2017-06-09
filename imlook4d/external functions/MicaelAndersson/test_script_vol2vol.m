%1)

%Vmall = spm_vol( 'E:\FILER\Lars Jonasson\Belöningsstudie\PT_Sharp\PT_Sharp_A01\wrA01_PT_Sharp');
Vmall = spm_vol( 'E:\FILER\Lars Nyberg\COBRA\COBRA - validering Logan\rc_fPT_rPETsh.nii');
Ymall = spm_read_vols(Vmall(1));
Vmall = Vmall(1);

Pstart = Vmall.mat(1:3,1:4)*[1 1 1 1]';
Pend = Vmall.mat(1:3,1:4)*[Vmall.dim 1]';
Vmall.vx = Pstart(1):Pend(1);
Vmall.vy = Pstart(2):Pend(2);
Vmall.vz = Pstart(3):Pend(3);
mallData = dz_InitBefore_dz_vol2vol(Vmall.dim);
mallData.Vmall = Vmall;
%%

%%2)

Vorig = spm_vol( 'E:\FILER\Lars Nyberg\COBRA\COBRA - validering Logan\aparc+aseg_NinasRev.nii');
Yorig = spm_read_vols(Vorig(1));
Vorig.dim = size(Yorig);
[Vny, Yny] = dz_vol2vol(Vorig, Yorig, mallData);