These files are the definitions for interactive help,
as started and stopped by the imlook4d toolbar button [?].

NOTE: The imlook4d version number is stored in About.txt, and is retrieved from there when needed by the program!

------------------------------------------------------------------------------------------
  ERRORS
------------------------------------------------------------------------------------------

Look for:
* Wrong callback name.  Look in "guide imlook4d" 
* Missing call to DisplayHelp (see MENU help, item 1, below)
* Wrong or missing help file name.

------------------------------------------------------------------------------------------
  PROGRAMMING   
------------------------------------------------------------------------------------------



	MENU help:
	---------
	1. Paste 

			% Display HELP and get out of callback
				 if DisplayHelp(hObject, eventdata, handles) 
					 %set(hObject,'State', 'off')  % This is commented out for menus, and toogle toolbars, but active for 
					 return 
				 end
	   
		into the menu callback function.

		For instance for the "File/Save" menu,
		paste the above text into the SaveFile_Callback function.



	2. Name a text file after the menu text-string, into imlook4d\HELP directory.    
	   For instance for the "File/Save" menu, the file text file Save.txt is created.


	3.  Write the html-code, but leave out the <html> and </html> tags.  The footer.txt will be


	TOOLBAR-BUTTON help:
	--------------------

	1. Do the above steps (as for a menu help).

	2. View the "Clicked callback", and copy the callback-text.
	3. Restore Defaults.
	4. Paste the callback-text into "On Callback"



	TEXT-FIELD or SLIDER help:
	--------------------------

	1. Do the above steps (as for a menu help).

	2. View the "Callback", and copy the callback-text.
	3. Paste the callback-text into "ButtonDownFunction"

	4. In the code,
		function helpToggleTool_OnCallback
			set(handles.PC_low_edit,'Enable', 'inactive');

		function helpToggleTool_OffCallback
			set(handles.PC_low_edit,'Enable', 'on');



	COLORMAP help:
	--------------------

	1. See README.txt in COLORMAP folder.


------------------------------------------------------------------------------------------
  HTML
------------------------------------------------------------------------------------------

	.txt documents are named according to the GUI item's Label or Tag.  Footer is inserted from Footer.txt.
	.html documents are static documents, that can be linked to.

	HELP file syntax
	-----------------
	- Is a .txt document, named according to the GUI item's Label or Tag.
	- No <html> tags should be included.  They are automatically added together with footer.
	- The BASE tag is automatically set to the HELP directory.
	  Thus, references to static features, such as images and static html documents can be made relative the HELP directory.
	- A good style example can be found in Open.txt




	LINK to bookmark in document 
	-----------------------
	1) The bookmark has an id.  Example of a bookmark with id=ITK:
	 <h2><a id="ITK">ITK file opening</a></h2>
	 
	2) Link to the bookmark, using javascript (to override the base path).  Example linking to the bookmark ITK:
	<a href="javascript:;" onclick="document.location.hash='ITK';">ITK</a>


	LINK to static document (works for any static documents in MATLAB path)
	-----------------------
	Can end with extensions recognized by operating system.	
	
	<A href="matlab:open( which('imlook4d_documentation.doc') );">imlook4d_documentation.doc</A>.
 
	

	LINK to static document (works for calls from interactive help)
	-----------------------
	Must end with .html, and contain complete html syntax.
	
	<a href="\export_details.html">Detailed information</a> 
	
	The path is relative HELP folder

	See export_details.html



	Images in html-code:
	--------------------

	imlook4d will append a BASE tag pointing to imlook4d/HELP.
	Images put into imlook4d/HELP/Images will be referenced as

	   <img src="\Images\Button_questionmark.jpg" alt="[?]" align="middle" > </img>

	See footer.txt.



	Tool-tip string in html-code:
	-----------------------------

	Putting for instance the DICOM tag as a tool-tip string can be achieved as:
	   <U><SPAN title="Tag='0028', '1053'">Rescale Slope</SPAN></U>
	where U tag stands for underline.  The text "Tag='0028', '1053'" will be displayed when hoovering over the text "Rescale Slope".

	See Open.txt.





	LINK to matlab CODE
	-------------------
	<a href="matlab:handles=guiData(gcf);set(handles.helpToggleTool,'State','off')">
	Disable help on current figure
	</a>

	See Footer.txt
