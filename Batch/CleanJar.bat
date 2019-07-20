::replace respDir with your repository path
set respDir="D:\apache-maven-3.5.3\repository"
set REPOSITORY_PATH=%respDir%
rem Searching for damaged jar...
for /f "delims=" %%i in ('dir /b /s "%REPOSITORY_PATH%\*lastUpdated*"') do (
    del /s /q %%i
)
rem Clean completed!
pause