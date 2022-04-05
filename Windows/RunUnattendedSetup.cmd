@echo off
powershell -ExecutionPolicy Bypass ".\Windows.ps1 -Unattended $true -GetExtras $false -MachineType 1" -Verb runAs -noexit
pause