org = load('/Users/jan/Documents/Projects/imlook4d/imlook4d_DEVELOP/imlook4d/imlook4d_org.fig','-mat');
emp  = load('/Users/jan/Documents/Projects/imlook4d/imlook4d_DEVELOP/imlook4d/empty.fig','-mat');

%%
% Fill emp(ty) with callbacks from org
emp.hgS_070000.properties.CloseRequestFcn = org.hgS_070000.properties.CloseRequestFcn;
%emp.hgS_070000.properties.ResizeFcn = org.hgS_070000.properties.ResizeFcn ;
emp.hgS_070000.properties.WindowButtonDownFcn = org.hgS_070000.properties.WindowButtonDownFcn; 
emp.hgS_070000.properties.WindowButtonMotionFcn = org.hgS_070000.properties.WindowButtonMotionFcn;
emp.hgS_070000.properties.WindowScrollWheelFcn = org.hgS_070000.properties.WindowScrollWheelFcn;
% 
% emp.hgS_070000.properties.Position = org.hgS_070000.properties.Position;
% emp.hgS_070000.properties.Color = org.hgS_070000.properties.Color;
% emp.hgS_070000.properties.PaperPosition = org.hgS_070000.properties.PaperPosition;
% emp.hgS_070000.properties.PaperSize = org.hgS_070000.properties.PaperSize;
% %emp.hgS_070000.properties.PaperSizeMode = org.hgS_070000.properties.PaperSizeMode; 
% emp.hgS_070000.properties.PaperType = org.hgS_070000.properties.PaperType;
% emp.hgS_070000.properties.ScreenPixelsPerInchMode = org.hgS_070000.properties.ScreenPixelsPerInchMode;
% % %emp.hgS_070000.properties.HandleVisibility = org.hgS_070000.properties.HandleVisibility;
% emp.hgS_070000.properties.PaperUnits = org.hgS_070000.properties.PaperUnits;
% emp.hgS_070000.properties.Units = org.hgS_070000.properties.Units;
% emp.hgS_070000.properties.Tag = org.hgS_070000.properties.Tag;
% emp.hgS_070000.properties.Name = org.hgS_070000.properties.Name;
% emp.hgS_070000.properties.FileName = org.hgS_070000.properties.FileName;
% % %emp.hgS_070000.properties.Number = org.hgS_070000.properties.Number;
% % 
% emp.hgS_070000.properties.CurrentAxesMode = 'manual';
% 
% 
% % Add empty figure properties to original struct (keeping everything else)
org.hgS_070000.properties = emp.hgS_070000.properties;

% Write into struct without the org prefix
hgS_070000 = org.hgS_070000;
hgM_070000 = org.hgM_070000;

save('/Users/jan/Documents/Projects/imlook4d/imlook4d_DEVELOP/imlook4d/imlook4d.fig','hgS_070000','-mat');
disp('Done')

imlook4d

%%
mod = load('/Users/jan/Documents/Projects/imlook4d/imlook4d_DEVELOP/imlook4d/imlook4d.fig','-mat');
