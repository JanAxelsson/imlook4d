TO CREATE A COLORMAP
--------------------

1) Create colormap following Red_white_blue.m (Use ”_” for spaces)

2) Make a .png file (Red_white_blue.png) for the EDIT/COLOR menu. 
   - imlook4d, open any image
   - for i=1:256;imlook4d_Cdata(i,:,1,1)=(i-1);end;Import
   - make a screen dump looking like a horizontal colorbar.  Save as xxx.png 
     (Red_white_blue.png).

2) Create a help file describing the colormap and place into /HELP folder
   using ”HELP/Red white blue.txt” as a template.   (Use ” ” for space”


Example
-------

Want to create colormap REDISH

1) Created a colormap called Redish.m
2) In HELP folder:  Copied Sokolof.txt to Redish.txt, and edited this help-text.
