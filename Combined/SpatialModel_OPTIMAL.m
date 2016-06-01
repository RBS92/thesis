function posAggregators = SpatialModel_OPTIMAL(R,n);

optimalfile = ['cci',num2str(n)];
cci = load(['cci_coords/',optimalfile,'.txt']);
cci = reshape(cci,n,3);
cci = cci*R;

posAggregators = cci(:,2:3);