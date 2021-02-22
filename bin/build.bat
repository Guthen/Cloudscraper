@echo off

:: compress
::powershell "Compress-Archive -Path """../*""" -Force  -DestinationPath """Cloudscraper.zip""""
::compact.exe /C Cloudscraper/*
::tar -C Cloudscraper --exclude="bin" --exclude=".git*" --format=ustar -cvf Cloudscraper/bin/Cloudscraper.love *

:: create .exe
copy /b love.exe+Cloudscraper.love Cloudscraper.exe

::  delete archive
::del Cloudscraper.zip

pause