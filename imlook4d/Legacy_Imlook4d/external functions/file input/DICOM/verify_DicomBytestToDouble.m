imageStruct = OpenDicom( [parentDir( which('imlook4d')) filesep 'test_data' filesep 'PET-Hoffman' filesep '[PT] AC Brain (2X5 min) - serie7' filesep '1' ] );
imagenr = 1; 

out = dirtyDICOMHeaderData(imageStruct.dirtyDICOMHeader, imagenr, '0009','1071',2);
disp([ 'VR=' out.valueRepresentation ' tag=' tag ' : ' num2str( DicomBytesToDouble( out.valueRepresentation, out.bytes) ) ' : 7.3101668E7  expected']);

tag='(0028,0107)';
out = dirtyDICOMHeaderData(imlook4d_current_handles.image.dirtyDICOMHeader,imagenr , tag(2:5),tag(7:10),2);
disp([ 'VR=' out.valueRepresentation ' tag=' tag ' : ' num2str( DicomBytesToDouble( out.valueRepresentation, out.bytes) ) ' : 32767  expected']);

tag='(0054,1321)';
out = dirtyDICOMHeaderData(imlook4d_current_handles.image.dirtyDICOMHeader, imagenr, tag(2:5),tag(7:10),2);
disp([ 'VR=' out.valueRepresentation ' tag=' tag ' : ' num2str( DicomBytesToDouble( out.valueRepresentation, out.bytes) ) ' : 1.01587  expected']);

tag='(0054,1202)';
out = dirtyDICOMHeaderData(imlook4d_current_handles.image.dirtyDICOMHeader, imagenr, tag(2:5),tag(7:10),2);
disp([ 'VR=' out.valueRepresentation ' tag=' tag ' : ' num2str( DicomBytesToDouble( out.valueRepresentation, out.bytes) ) ' : 2  expected']);


tag='(0018,1076)';
out = dirtyDICOMHeaderData(imlook4d_current_handles.image.dirtyDICOMHeader, imagenr, tag(2:5),tag(7:10),2);
disp([ 'VR=' out.valueRepresentation ' tag=' tag ' : ' num2str( DicomBytesToDouble( out.valueRepresentation, out.bytes) ) ' : 0.96700000762939  expected']);

