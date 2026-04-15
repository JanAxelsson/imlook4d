function [Y V] = jan_read_nii_niigz( filename)

    [filepath,name,ext] = fileparts(filename);
    
    if strcmp( ext, '.gz')
        tempNifti = gunzip( filename ); 
        tempNifti = tempNifti{1};
        V = spm_vol(tempNifti);   % Header
        Y  = spm_read_vols(V);  % Volume 
        delete(tempNifti); % Delete temporary nifti
    else
        nifti = filename;
        V = spm_vol(nifti);   % Header
        Y  = spm_read_vols(V);  % Volume 
    end


