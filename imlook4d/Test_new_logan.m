b1=ReferenceLogan( imlook4d_ROI_data)
b1.setReferenceRegion(3)
b1.calculateNewCoordinates()

b1.setFrameRange(10:21)
b1.fitModel()