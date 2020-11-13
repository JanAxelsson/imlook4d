---
title: Projects
author: Jan Axelsson
---

Folders and files
-----------------

`📁imlook4d_DEVELOP` (**git respository**)

`📁imlook4d`

`📁USER_SCRIPTS` (soft link to `📁USER_SCRIPTS_DEVELOP`)

`📁imlook4d-exports` (zip file of releases, from running
`imlook4d-export-to-zip`)

`📁Test data`

`📁USER_SCRIPTS_DEVELOP` (**git repository**)

📄`imlook4d-export-to-zip` (creates a zip-file with release in
`📁imlook4d-exports`)

 

imlook4d repository
-------------------

-   `imlook4d_DEVELOP`, is the main project, and lives in its own git
    repository.

    -   `imlook4d_DEVELOP/imlook4d` (is the location of the imlook4d software
        from this project)

    -   `imlook4d_DEVELOP/USER_SCRIPTS` (is a folder intended for user's
        scripts)

Create a release
----------------

-    

-    

-   Creating a release from a ”tag” in the git repository, run the script
    `imlook4d-export-to-zip`. This will place a zip file with correct
    version.txt in the folder `imlook4d-exports`. The zip file can be
    distributed as is.

-   **Note**: the tagged release will not have the correct `version.txt`, since
    this is added in the script `imlook4d-export-to-zip`.

Make release available
----------------------

-   Starta Google Drive

-   Kopiera zip-file  
    från: `/Users/jan/Documents/Projects/imlook4d/imlook4d-exports`  
    till: `/Users/jan/Google Drive/imlook4d-site/downloads/Current release`

-   Editera `/Users/jan/Google
    Drive/imlook4d-site/downloads/latest_releases.txt`  
    (instruktion inne i den filen)

 

USER_SCRIPTS repository
-----------------------

-   `USER_SCRIPTS_DEVELOP`, is another git repository, used for files that may
    be placed in `USER_SCRIPTS`.

 
