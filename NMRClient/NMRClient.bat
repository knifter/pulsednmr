@echo off
set INSTALLDIR=C:\NMRClient
set CONDA_PREFIX=%INSTALLDIR%\env
set QTDIR=%CONDA_PREFIX%\Library\bin
set QT_QPA_PLATFORM_PLUGIN_PATH=%QTDIR%\plugins\platforms\
set PATH=%CONDA_PREFIX%;%QTDIR%;%PATH%
start "NMRClient Startup.." pythonw nmr.py
