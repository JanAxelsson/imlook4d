REM Used as a pre-commit hook in Tortoise-svn on Windows.
REM 
REM Tortoise-svn setting / Hook scripts / 
REM 	Hook type:   
REM			Pre-commit hook
REM     Working copy path:   
REM			C:\Users\Jan\Documents\programmering\imlook4d_DEVELOP
REM		Command line to execute:   
REM			C:\Users\Jan\Documents\programmering\imlook4d_DEVELOP\pre-commit-hook.bat
REM 
svnversion -n "C:\Users\Jan\Documents\programmering\imlook4d_DEVELOP" >  "C:\Users\Jan\Documents\programmering\imlook4d_DEVELOP\version.txt"
exit 0
