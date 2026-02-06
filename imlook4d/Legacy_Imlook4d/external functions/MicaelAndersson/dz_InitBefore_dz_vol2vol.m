function mall = dz_InitBefore_dz_vol2vol(dim)

	nct = dim(1);
	nrt = dim(2);
	nst = dim(3);
	nvt = prod(dim);

	[tc tr ts] = meshgrid(1:nct, 1:nrt, 1:nst);
	mall.nct = nct;
	mall.nrt = nrt;
	mall.nst = nst;
	mall.tc = tc;
	mall.tr = tr;
	mall.ts = ts;
	mall.tcrs = [tc(:) tr(:) ts(:) ones(nvt,1)]';
	mall.tind = tc+(tr-1)*dim(1)+(ts-1)*dim(1)*dim(2);
	
	
	
