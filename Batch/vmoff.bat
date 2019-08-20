@echo off & setlocal enabledelayedexpansion
echo "Shutdown Hadoop Cluster..."
vmrun list > vmlist.txt
for %%i in (vmlist.txt) do (
    set "f=%%i"
    for /f "usebackq delims=" %%j in ("!f!") do set/a n+=1
    for /f "delims=" %%m in ('"type "!f!"|more /E +1 & cd. 2^>!f!"') do set/a x+=1&if !x! leq !n! echo;%%m>>!f!
    set/a n=0,x=0
)
for /f "delims=" %%a in (vmlist.txt) do (
     vmrun -T ws stop "%%a" nogui
)
del /F /Q vmlist.txt