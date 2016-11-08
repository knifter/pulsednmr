#!/usr/bin/env python

# Control program for the Red Pitaya Pulsed NMR system
# Copyright (C) 2015  Pavel Demin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import sys
import struct

# print("PATH: %s" % str(sys.path))

from PyQt5.uic import loadUiType
from PyQt5.QtWidgets import QApplication\
    #, QMainWindow, QMenu, QVBoxLayout, QSizePolicy, QMessageBox, QWidget


from nmrctrl import NMRCtrl

import logutil
import logging

import mainwindow

LOG_ROOT = 'nmr'
LOG_NAME = 'nmr.gui'
LOG_FILE = 'client.log'

# Ui_PulsedNMR, QMainWindow = loadUiType('pulsed_nmr.ui')

def main():
    logutil.RemoveRootHandlers()
    logutil.AddLogHandler(LOG_ROOT, logging.DEBUG)
    logutil.AddLogHandler(LOG_ROOT, logging.CRITICAL, filename=LOG_FILE, formatter=logutil.LogFileFormatter())
    sys.excepthook = excepthook

    app = NMRClientApp()

    sys.exit(app.exec_())

    # app = QApplication(sys.argv)
    # window = PulsedNMR()
    # window.show()

class NMRClientApp(QApplication):
    def __init__(self):
        super(NMRClientApp, self).__init__([])
        self._log = None

        self.nmr = NMRCtrl()
        self.mw = mainwindow.MainWindow(self)

    def exec_(self):
        self.onStart()
        super(NMRClientApp, self).exec_()
        self.onStop()

    def onStart(self):
        self.mw.show()
        self.mw.action_Connect()

    def onStop(self):
        pass

def excepthook(type_, value, tb):
    log = logging.getLogger('pymot')
    # Try logging the exception
    try:
        tb_list = traceback.format_tb(tb, 10)
        tb_str = "".join(tb_list)
        name = type_.__name__
        # tb_last = tb
        # while tb_last.tb_next:
        #     tb_last = tb_last.tb_next
        # linenr = tb_last.tb_frame.f_lineno
        log.fatal("Uncatched Exception: %s: %s" % (name, value))
        log.info("Traceback for '%s':\n%s" % (name, tb_str))
    except:
        # fallback
        sys.__excepthook__(type_, value, tb)

if __name__ == "__main__":
    main()
