@echo off
set INSTALLDIR=C:\NMRClient
set CONDA_PREFIX=%INSTALLDIR%\env
set PATH=%CONDA_PREFIX%;%PATH%
start "NMRClient Startup.." pythonw nmr.py
