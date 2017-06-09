function hideMatlab()

frames = java.awt.Frame.getFrames;
for frameIdx = 1 : length(frames)
   try
      awtinvoke(frames(frameIdx),'setVisible',0);
   catch
      % never mind...
   end
end