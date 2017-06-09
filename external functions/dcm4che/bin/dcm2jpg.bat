@echo off
rem -------------------------------------------------------------------------
rem dcm4che2/dcm2jpg  Launcher
rem -------------------------------------------------------------------------

rem $Id: dcm2jpg.bat 826 2007-04-27 13:35:50Z gunterze $

rem Need jai-imageio-1.1 installed!! 
rem (download from https://jai-imageio.dev.java.net/binary-builds.html)
rem For CLASSPATH Installation,
rem set JIO_LIB="C:\Program Files\Sun Microsystems\JAI Image IO Tools 1.1\lib"

if not "%ECHO%" == ""  echo %ECHO%
if "%OS%" == "Windows_NT"  setlocal

set MAIN_CLASS=org.dcm4che2.tool.dcm2jpg.Dcm2Jpg
set MAIN_JAR=dcm4che-tool-dcm2jpg-2.0.19.jar

set DIRNAME=.\
if "%OS%" == "Windows_NT" set DIRNAME=%~dp0%

rem Read all command line arguments

set ARGS=
:loop
if [%1] == [] goto end
        set ARGS=%ARGS% %1
        shift
        goto loop
:end

if not "%DCM4CHE_HOME%" == "" goto HAVE_DCM4CHE_HOME

set DCM4CHE_HOME=%DIRNAME%..

:HAVE_DCM4CHE_HOME

if not "%JAVA_HOME%" == "" goto HAVE_JAVA_HOME

set JAVA=java

goto SKIP_SET_JAVA_HOME

:HAVE_JAVA_HOME

set JAVA=%JAVA_HOME%\bin\java

:SKIP_SET_JAVA_HOME

set CP=%DCM4CHE_HOME%\etc\
set CP=%CP%;%DCM4CHE_HOME%\lib\%MAIN_JAR%
set CP=%CP%;%DCM4CHE_HOME%\lib\dcm4che-core-2.0.19.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\dcm4che-image-2.0.19.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\dcm4che-imageio-2.0.19.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\dcm4che-imageio-rle-2.0.19.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\slf4j-log4j12-1.5.0.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\slf4j-api-1.5.0.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\log4j-1.2.13.jar
set CP=%CP%;%DCM4CHE_HOME%\lib\commons-cli-1.1.jar

if "%JIO_LIB%" == "" goto :SKIP_SET_JIO_CLASSPATH

set CP=%JIO_LIB%\jai_imageio.jar;%JIO_LIB%\clibwrapper_jiio.jar;%CP%
set PATH=%JIO_LIB%;%PATH%

:SKIP_SET_JIO_CLASSPATH

"%JAVA%" %JAVA_OPTS% -cp "%CP%" %MAIN_CLASS% %ARGS%

