
import matplotlib
import numpy as np
from nmrctrl import NMRMeasurement

import logging
LOG_ROOT = 'nmr'
LOG_NAME = 'nmr.plotwidgets'
log = logging.getLogger(LOG_NAME)

QT_VERSION = 5
if QT_VERSION == 4:
    # Qwidget
    pass
if QT_VERSION == 5:
    from PyQt5.QtWidgets import QWidget, QGridLayout, QGroupBox
    matplotlib.use('Qt5Agg')
    from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
    from matplotlib.backends.backend_qt5agg import NavigationToolbar2QT as NavigationToolbar

from matplotlib.figure import Figure

class PlotWidget(QWidget):
    def __init__(self, parent=None, title=None):
        super(PlotWidget, self).__init__(parent)

        self._rate = 10
        self._size = 10
        self._avg = 1
        self._avgdata = None
        self._ignore_us = 0
        self._ignore_samples = 0
        self.curveA = None
        self.curveB = None
        self._avgdata = None

        self.createWidget(title)

    def createWidget(self, title = None):
        # Layout
        mainlayout = QGridLayout()
        # mainlayout.setMargin(0)
        layout = QGridLayout()

        # title
        self.frame = QGroupBox()
        if(title):
            self.frame.setTitle(title)

        # create figure
        figure = Figure()
        figure.set_facecolor('none')
        self.axis = figure.add_subplot(111)
        self.canvas = FigureCanvas(figure)
        layout.addWidget(self.canvas)

        # create navigation toolbar, remove subpluts action
        self.toolbar = NavigationToolbar(self.canvas, self, False)
        actions = self.toolbar.actions()
        self.toolbar.removeAction(actions[7])
        layout.addWidget(self.toolbar)

        # final layout
        self.frame.setLayout(layout)
        mainlayout.addWidget(self.frame)
        self.setLayout(mainlayout)

    def initPlot(self):
        #toolbar
        #self.toolbar.home()
        #self.toolbar._views.clear()
        #self.toolbar._positions.clear()

        self._avgdata = None

    @property
    def _ignore_total(self):
        return min(int(self._ignore_us * self._rate / 1E6 + self._ignore_samples), self._size)

    def setTitle(self, title):
        self.frame.setTitle(title)

    def setSampleSize(self, size):
        self._size = size

    def setSampleRate(self, rate):
        self._rate = rate

    def setAverageCount(self, cnt):
        self._avg = max(cnt, 1)

    def set_rate(self, rate):
        self._rate = int(rate)
        self.initPlot()

    def set_size(self, size):
        self._size = int(size)
        self.initPlot()

    def set_ignore(self, us = None, samples = None):
        if us != None:
            self._ignore_us = us
        if samples != None:
            self._ignore_samples = samples
        log.debug("ignoring a total of %d samples (%d us + %s samples)."
                  % (self._ignore_total, self._ignore_us, self._ignore_samples))
        self.initPlot()

class PlotTimeWidget(PlotWidget):
    def __init__(self, parent=None, title=None):
        super(PlotTimeWidget, self).__init__(parent)
        self._mode = 'A'

        self.initPlot()

    def initPlot(self):
        size = self._size
        rate = self._rate
        ignore = self._ignore_total

         # configure time axis
        time = np.linspace(0.0, (size - 1) * 1E6 / rate, size)
        zeros = np.zeros(len(time))

        # configure axis
        self.axis.clear()
        self.axis.grid()
        self.curveA = self.axis.plot(time[0:ignore], zeros[0:ignore], '0.50')[0]
        self.curveB = self.axis.plot(time[ignore-1:], zeros[ignore-1:], 'b')[0]
        x1, x2, y1, y2 = self.axis.axis()
        self.axis.axis((x1, x2, -0.1, 0.4))
        self.axis.set_xlabel('t [us]')

        self._avgdata = None

    def updatePlot(self, m:NMRMeasurement):
        if m.rate != self._rate:
            self.set_rate(m.rate)
        if m.size != self._size:
            self.set_size(m.size)

        # select the right data depending on the mode
        data = None
        if self._mode == 'A':
            data = np.abs(m.iqdata)
        if self._mode == 'I':
            data = m.iqdata.real
        if self._mode == 'IQ':
            ValueError("Not supported")

        # stream through the averager
        if self._avgdata is None or (len(self._avgdata) != len(data)):
            self._avgdata = data
        self._avgdata = (self._avg - 1) * self._avgdata + data
        self._avgdata = self._avgdata / self._avg

        # plot zeros and store the returned Line2D object
        ignore = self._ignore_total
        self.curveA.set_ydata(self._avgdata[0:ignore])
        self.curveB.set_ydata(self._avgdata[ignore-1:])
        self.canvas.draw()

    def set_mode(self, mode):
        if mode not in ['I', 'IQ', 'A']:
            ValueError("Invalid mode: %s" % (mode))
        self._mode = mode
        self._avgdata = None
        # self.initPlot()


class PlotFFTWidget(PlotWidget):
    def __init__(self, parent=None, title=None):
        super(PlotFFTWidget, self).__init__(parent)

        self._freq_offset = 0

        self.initPlot()

    def initPlot(self):
        size = self._size
        rate = self._rate
        ignore = self._ignore_total

        fftsize = max(size - ignore, 1) # no zeroes here
        freqs = np.fft.fftshift(np.fft.fftfreq(fftsize, d=float(1 / rate))) + self._freq_offset

        # configure axis'
        self.axis.clear()
        self.axis.grid()
        self.curve = self.axis.plot(freqs/1E6, np.zeros(len(freqs)), 'b')[0]

        x1, x2, y1, y2 = self.axis.axis()
        self.axis.axis((x1, x2, 0, 1.1))
        self.axis.set_xlabel('F [MHz]')

        self._avgdata = None

    def updatePlot(self, m: NMRMeasurement):
        if m.rate != self._rate:
            self.set_rate(m.rate)
        if m.size != self._size:
            self.set_size(m.size)

        # create FFT
        ignore = self._ignore_total
        fft = np.abs(np.fft.fftshift(np.fft.fft(m.iqdata[ignore:], norm='ortho')))

        # stream through the averager
        if self._avgdata is None:
            self._avgdata = fft
        self._avgdata = (self._avg - 1) * self._avgdata + fft
        self._avgdata = self._avgdata / self._avg

        # plot zeros and store the returned Line2D object
        self.curve.set_ydata(self._avgdata)
        self.canvas.draw()

    def set_frequencyOffset(self, freq):
        self._freq_offset = freq
        self.initPlot()
