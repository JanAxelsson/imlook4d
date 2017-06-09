function [Vout, Yout, tindOut, mindOut, mcrs] = dz_vol2vol(V, Y, mallData)
% [V, Y] = dz_vol2vol(V, Y, tomat)
%

%trans = V.mat\mallData.Vmall.mat;
if numel(V)==1
	trans = inv(V.mat)*mallData.Vmall.mat;

	mcrs = round(trans(1:3,:)*mallData.tcrs);

	sz = size(Y);
	ncm = sz(1);
	nrm = sz(2);
	nsm = sz(3);
	nvm = numel(Y);

	mc = mcrs(1,:); %-1; % fortsätt här -1;
	mr = mcrs(2,:);
	ms = mcrs(3,:);

	indok = find(mc >= 1 & mc <= ncm & mr >= 1 & mr <= nrm & ms >= 1 & ms <= nsm);

	tind = mallData.tind(indok);

	mind = mc(indok)+(mr(indok)-1)*sz(1)+(ms(indok)-1)*sz(1)*sz(2);

	Vout = V;
	Vout.mat = mallData.Vmall.mat;
	Vout.dim = mallData.Vmall.dim;
	Yout = zeros(Vout.dim);
	Yout(tind) = Y(mind);
	if nargout>=3
		tindOut = tind;
		mindOut = mind;
	end
else
	diff = 0;
	for i=2:numel(V)
		diff = diff+dz_SumTot(V(1).mat~=V(i).mat);
	end
	Yout = NaN([mallData.Vmall.dim(:)' numel(V)]);
	if diff~=0 % if some V.mat differs
		for i=1:numel(V)
			trans = inv(V(i).mat)*mallData.Vmall.mat;

			mcrs = round(trans(1:3,:)*mallData.tcrs);

			sz = size(Y);
			ncm = sz(1);
			nrm = sz(2);
			nsm = sz(3);
			nvm = numel(Y);

			mc = mcrs(1,:);
			mr = mcrs(2,:);
			ms = mcrs(3,:);

			indok = find(mc >= 1 & mc <= ncm & mr >= 1 & mr <= nrm & ms >= 1 & ms <= nsm);

			basetind = mallData.tind(indok);
			
			basemind = mc(indok)+(mr(indok)-1)*sz(1)+(ms(indok)-1)*sz(1)*sz(2);

			Vout(i) = V(i);
			Vout(i).mat = mallData.Vmall.mat;
			Vout(i).dim = mallData.Vmall.dim;
			%Yout = zeros(Vout(i).dim);
			tind = basetind+(i-1)*prod(mallData.Vmall.dim);
			mind = basemind+(i-1)*prod(V(i).dim);
			Yout(tind) = Y(mind);
			if nargout>=3
				tindOut{i} = tind;
				mindOut{i} = mind;
			end
		end
	else
		trans = inv(V(1).mat)*mallData.Vmall.mat;

		mcrs = round(trans(1:3,:)*mallData.tcrs);

		sz = size(Y);
		ncm = sz(1);
		nrm = sz(2);
		nsm = sz(3);
		nvm = numel(Y);

		mc = mcrs(1,:);
		mr = mcrs(2,:);
		ms = mcrs(3,:);

		indok = find(mc >= 1 & mc <= ncm & mr >= 1 & mr <= nrm & ms >= 1 & ms <= nsm);

		basetind = mallData.tind(indok);

		basemind = mc(indok)+(mr(indok)-1)*sz(1)+(ms(indok)-1)*sz(1)*sz(2);

		for i=1:numel(V)
			Vout(i) = V(i);
			Vout(i).mat = mallData.Vmall.mat;
			Vout(i).dim = mallData.Vmall.dim;
			%Yout = zeros(Vout.dim);
			tind = basetind+(i-1)*prod(mallData.Vmall.dim);
			mind = basemind+(i-1)*prod(V(i).dim);
			Yout(tind) = Y(mind);
			if nargout>=3
				tindOut{i} = tind;
				mindOut{i} = mind;
			end
		end
	end
end

return





