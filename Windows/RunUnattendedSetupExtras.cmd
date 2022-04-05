@echo off
powershell -ExecutionPolicy Bypass ".\Windows.ps1 -Unattended $true -GetExtras $true -MachineType 1" -Verb runAs -noexit
pause