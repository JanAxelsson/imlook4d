%read_bs
%author: Hans Lundqvist, modified by Gunnar Blomqvist,and by Jan Axelsson
%created: 20th century modified 010405
%reads binary file from blood sampler
%
%input: 
%bs_file: file name blood sampler file
%%output: 
%bs_time: sampling time in blood sampler
%bs_count: detected counts in bs at times bs_time
%bs_dt: samoling time interval (default 1s)
%bs_n: number of measurements
%bs_calib: bs calibration factor (in file header of bs_file)
%
%function calls: none
%version	name	date		comment
%1.1        Jan      031127


function [bs_time, bs_count, bs_dt, bs_n, bs_calib]= read_bs(bs_file);
%read_bs reads binary blood-sampler file
%HL-routine modified March-2000

fidbs=fopen([bs_file],'r','vaxd'); 
if fidbs < 0
	error(['open error file' bs_file mess]);
end
%find calibration factor
status = fseek(fidbs, 24, 'bof');
bs_calib = fread(fidbs, [1,1], 'float'); 

%read data
status=fseek(fidbs,16*4,'bof');
[A, count] = fread(fidbs, [16,inf], 'int32');
bs_count = (A(4,:) + A(7,:))';
bs_n = count/16;
%read time
status=fseek(fidbs,16*4,'bof');
A=fread(fidbs, [16,inf], 'float');
bs_tid = A(1,:);		%time from 00:00
bs_time = A(2,:)';
bs_dt = A(3,:)';

disp(['Scanditronix blood stampler start time (in seconds from 00:00:00) = ' num2str(bs_tid(1,1)) ] );
fclose(fidbs);
