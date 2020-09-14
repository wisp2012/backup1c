REM Remove files older than 20 days
ForFiles /p "C:\Users\AS\Downloads" /s /d -20 /c "cmd /c del @file"