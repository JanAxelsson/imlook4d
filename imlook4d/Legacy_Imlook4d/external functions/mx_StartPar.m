%**************************************************************************
%Function Name: mx_StartPar
%Author: Anna Ringheim
%Created: 080313
%Description: Returns a struct of model specific start parameters.
%Input:
%Output: model (struct)
%Function calls:
%Revision history:
%Name	Date        Comment
%AR     080313      First version
%**************************************************************************


function model = mx_StartPar

%Close all open figures.
%JAN
%Define path to Matlab read/write functions and models directory. Change
%these if not on Uris_fs1 network.
model.functionpath = genpath('\\Uris_fs1\modeling\MatlabModuleLibrary\MatlabFunctions');
model.modelpath = '\\Uris_fs1\modeling\MatlabPrograms\mx\Models';

%Add path to Matlab Module Library directory and models directory.
addpath(model.functionpath);
%addpath(model.modelpath);

%Choose model.
model_list = {...
    'Input Bloodflow (iterative)',...
    'Input CBV (linear)',...
    'Input Irrev two-comp (linear)',...
    'Input Logan (linear)',...
    'Input Patlak (linear)',...
    'Reference SRTM (iterative)',...
    'Reference Logan (linear)',...
    'Reference Patlak (linear)',...
    'Reference Ratio (linear)',...
    'Sum Frames (linear)',...
    'Acetate Myocard (iterative)'...
    };

model_num = menu('Choose model: ', model_list);
switch model_list{model_num}
    case 'Input Bloodflow (iterative)',
        model.type = 'input';
        model.modelfile = 'mx_model_inp_itr_bloodflow';
        model.modeldata = {'blood', 'head'};
    case 'Input CBV (linear)',
        model.type = 'input';
        model.modelfile = 'mx_model_inp_lin_CBV';
        model.modeldata = {'blood'};
    case 'Input Irrev two-comp (linear)',
        model.type = 'input';
        model.modelfile = 'mx_model_inp_lin_lin3k';
        model.modeldata = {'blood'};
    case 'Input Logan (linear)',
        model.type = 'input';
        model.modelfile = 'mx_model_inp_lin_logan';
        model.modeldata = {'blood'};
    case 'Input Patlak (linear)',
        model.type = 'input';
        model.modelfile = 'mx_model_inp_lin_patlak';
        model.modeldata = {'blood'};
    case 'Reference SRTM (iterative)',
        model.type = 'reference';
        model.modelfile = 'mx_model_ref_itr_srtm';
        model.modeldata = {'tact'};
    case 'Reference Logan (linear)',
        model.type = 'reference';
        model.modelfile = 'mx_model_ref_lin_logan';
        model.modeldata = {'tact'};
    case 'Reference Patlak (linear)',
        model.type = 'reference';
        model.modelfile = 'mx_model_ref_lin_patlak';
        model.modeldata = {'tact'};
    case 'Reference Ratio (linear)',
        model.type = 'reference';
        model.modelfile = 'mx_model_ref_lin_refratio';
        model.modeldata = {'tact'};
    case 'Sum Frames (linear)',
        model.type = '';
        model.modelfile = 'mx_model_ref_lin_sumframes';
        model.modeldata = {''};
    case 'Acetate Myocard (iterative)',
        model.type = 'special';
        model.modelfile = 'mx_model_spec_itr_acemyocard';
        model.modeldata = {'tact'};
    otherwise
        error(['Unknown model: ' model_list{model_num}]);
        return
end
model.nr = model_num;
model.model_name = model_list{model_num};
disp(['Model: ' model_list{model_num}]);

%Give tracer.
tracer = inputdlg('Give tracer name: ','Tracer input');
model.tracer = upper(tracer);
