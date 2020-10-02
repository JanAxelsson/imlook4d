#!/usr/local/bin/python3
# 
# Prerequisite (start in same python as first row): 
# /usr/local/bin/python3 -m pip install pydrive
import os
import sys
from pydrive.drive import GoogleDrive
from pydrive.auth import GoogleAuth

file_id = '1A_3nhoQsr4_djNum_yiFcO4dm3Ctbxkx'
file_id = sys.argv[1]

fileToUpload = '/Users/jan/Documents/Projects/imlook4d/imlook4d_DEVELOP/release to google drive/test_google_api.py'
fileToUpload = sys.argv[2]


#
# Try to load saved client credentials
#
print('Logging in to Google Drive')
gauth = GoogleAuth()
gauth.LoadCredentialsFile("mycreds.txt")
if gauth.credentials is None:
    # Authenticate if they're not there
    gauth.LocalWebserverAuth()
elif gauth.access_token_expired:
    # Refresh them if expired
    gauth.Refresh()
else:
    # Initialize the saved creds
    gauth.Authorize()
# Save the current credentials to a file
gauth.SaveCredentialsFile("mycreds.txt")
drive = GoogleDrive(gauth)

#
# Upload to drive and folderID
#

folderName, fileName = os.path.split(fileToUpload)
print('Uploading File = %s' % fileName)
file = drive.CreateFile({'id': file_id }) 
file.SetContentFile(fileToUpload)
file.Upload()

print('Updated Google Drive File-ID = %s' % (file['id']))

# Store in file
print('Google Drive File-ID written to file = %s' % ('/tmp/gdrive_id.txt') )
with open('/tmp/gdrive_id.txt', 'w') as the_file:
    the_file.write(file['id'])
