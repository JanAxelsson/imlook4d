function test_script_from_function( )

% INPUTS = Parameters( {'test^person ', '12345', ' WB 3D MAC ', '6 ', 'SERUME000000000'} );
% INPUTS = Parameters( {'C:\Users\Jan\Desktop\test'} );
% Menu('Save')

INPUTS = Parameters( {'E:\FILER\Huang BS\11337PETKi\IM22'} );
imlook4d_current_handle = Open(INPUTS{1}); % Handle to imlook4d window
