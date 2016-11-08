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

print("PATH: %s" % str(sys.path))

import numpy as np

from PyQt5.uic import loadUiType
from PyQt5.QtCore import QRegExp, QTimer
from PyQt5.QtGui import QRegExpValidator
from PyQt5.QtWidgets import QApplication, QMainWindow, QMenu, QVBoxLayout, QSizePolicy, QMessageBox, QWidget
from PyQt5.QtNetwork import QAbstractSocket, QTcpSocket

import matplotlib
matplotlib.use('Qt5Agg')
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.backends.backend_qt5agg import NavigationToolbar2QT as NavigationToolbar
from matplotlib.figure import Figure

Ui_PulsedNMR, QMainWindow = loadUiType('pulsed_nmr.ui')

class PulsedNMR(QMainWindow, Ui_PulsedNMR):
  rates = {0:2500.0e3, 1:1250.0e3, 2:500.0e3, 3:250.0e3, 4:125.0e3, 5:50.0e3, 6:25.0e3}
  def __init__(self):
    super(PulsedNMR, self).__init__()
    self.setupUi(self)
    self.rateValue.addItems(['2500', '1250', '500', '250', '125', '50', '25'])

    # IP address validator
    rx = QRegExp('^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$')
    self.addrValue.setValidator(QRegExpValidator(rx, self.addrValue))
    # state variable
    self.idle = True

    # number of samples to show on the plot
    self.size = 50000

    # buffer and offset for the incoming samples
    self.buffer = bytearray(8 * self.size)
    self.offset = 0
    self.data = np.frombuffer(self.buffer, np.complex64)

    # create figure
    figure = Figure()
    figure.set_facecolor('none')
    self.axes = figure.add_subplot(111)
    self.canvas = FigureCanvas(figure)
    self.plotLayout.addWidget(self.canvas)
    # create navigation toolbar
    self.toolbar = NavigationToolbar(self.canvas, self.plotWidget, False)
    # remove subplots action
    actions = self.toolbar.actions()
    self.toolbar.removeAction(actions[7])
    self.plotLayout.addWidget(self.toolbar)
    self.plotmode = 'time'

    # create TCP socket
    self.socket = QTcpSocket(self)
    self.socket.connected.connect(self.connected)
    self.socket.readyRead.connect(self.read_data)
    self.socket.error.connect(self.display_error)

    # connect signals from buttons and boxes
    self.startButton.clicked.connect(self.start)
    self.freqValue.valueChanged.connect(self.set_freq)
    self.awidthValue.valueChanged.connect(self.set_awidth)
    self.deltaValue.valueChanged.connect(self.set_delta)
    self.rateValue.currentIndexChanged.connect(self.set_rate)

    # set rate
    self.rateValue.setCurrentIndex(2)

    # create timer for the repetitions
    self.timer = QTimer(self)
    self.timer.timeout.connect(self.fire)

  def start(self):
    if self.idle:
      self.startButton.setEnabled(False)
      self.socket.connectToHost(self.addrValue.text(), 1001)
    else:
      self.idle = True
      self.timer.stop()
      self.socket.close()
      self.offset = 0
      self.startButton.setText('Start')
      self.startButton.setEnabled(True)

  def connected(self):
    self.idle = False
    self.set_freq(self.freqValue.value())
    self.set_rate(self.rateValue.currentIndex())
    self.set_awidth(self.awidthValue.value())
    self.fire()
    self.timer.start(self.deltaValue.value())
    self.startButton.setText('Stop')
    self.startButton.setEnabled(True)

  def read_data(self):
    size = self.socket.bytesAvailable()
    if self.offset + size < 8 * self.size:
      self.buffer[self.offset:self.offset + size] = self.socket.read(size)
      self.offset += size
    else:
      self.buffer[self.offset:8 * self.size] = self.socket.read(8 * self.size - self.offset)
      self.offset = 0
      # plot the signal envelope
      self.curve.set_ydata(np.abs(self.data))
      self.canvas.draw()
      self.update_plot(self.data)

  def update_plot(self, data):
    if self.plotmode == 'time':
      self.plot_time(data)
    else:
      self.plot_fft(data)

  def plot_time(self, data):
    self.curve.set_ydata(np.abs(self.data))
    self.canvas.draw()

  def plot_fft(self, data):
    n = len(data);
    #      k = np.arange(n);
    #      Fs = 500.0e6;
    #      T = n/Fs;
    #      frq = int(k/T);
    #      frq = frq[range(n/2)];
    Y = np.fft.fft(data)
    #      Y = Y[range(n/2)]

    self.curve.set_ydata(np.abs(Y))
    self.canvas.draw()

  def display_error(self, socketError):
    if socketError == QAbstractSocket.RemoteHostClosedError:
      pass
    else:
      QMessageBox.information(self, 'PulsedNMR', 'Error: %s.' % self.socket.errorString())
    self.startButton.setText('Start')
    self.startButton.setEnabled(True)

  def set_freq(self, value):
    if not self.idle:
      self.socket.write(struct.pack('<I', 0<<28 | int(1.0e6 * value)))

  def set_rate(self, index):
    self.current_rate = float(PulsedNMR.rates[index])

    # time axis
    time = np.linspace(0.0, (self.size - 1) * 1000.0 / self.current_rate, self.size)

    # reset toolbar
    self.toolbar.home()
    self.toolbar._views.clear()
    self.toolbar._positions.clear()

    # reset plot
    self.axes.clear()
    self.axes.grid()

    # plot zeros and get store the returned Line2D object
    self.curve, = self.axes.plot(time, np.zeros(self.size))
    x1, x2, y1, y2 = self.axes.axis()
    # set y axis limits
    self.axes.axis((x1, x2, -0.1, 0.4))
    self.axes.set_xlabel('time, ms')
    self.canvas.draw()

    # set repetition time
    minimum = self.size / self.current_rate * 2000.0
    if minimum < 100.0:
      minimum = 100.0
    self.deltaValue.setMinimum(minimum)
    #    self.deltaValue.setValue(minimum)

    # Update pitaya (if running)
    if not self.idle:
      self.socket.write(struct.pack('<I', 1<<28 | index))

  def set_awidth(self, value):
    if self.idle: return
    self.socket.write(struct.pack('<I', 2<<28 | int(1.0e1 * value)))

  def set_delta(self, value):
    if self.idle: return
    self.timer.stop()
    self.timer.start(value)

  def fire(self):
    if self.idle: return
    self.socket.write(struct.pack('<I', 3<<28))

def main():
  app = QApplication(sys.argv)
  window = PulsedNMR()
  window.show()
  sys.exit(app.exec_())

if __name__ == "__main__":
  main()
