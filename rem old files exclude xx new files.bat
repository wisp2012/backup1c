REM Remove old files, exclud N files
@Echo Off

Set "Where=C:\Users\user\Downloads"
Set "Mask=*.*"
Set /A N=30

FOR /F "usebackq Skip=%N% delims=" %%f IN (`Dir /b /A:-D /O:-D /T:W "%Where%\%Mask%" 2^>nul`) DO Echo Del "%Where%\%%f"