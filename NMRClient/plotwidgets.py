
import logging
import matplotlib
import numpy as np
from nmrctrl import NMRMeasurement
from PyQt5.QtWidgets import QWidget, QGridLayout, QGroupBox
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg
from matplotlib.backends.backend_qt5agg import NavigationToolbar2QT
from matplotlib.figure import Figure

LOG_ROOT = 'nmr'
LOG_NAME = 'nmr.plotwidgets'
log = logging.getLogger(LOG_NAME)

matplotlib.use('Qt5Agg')


class PlotWidget(QWidget):
    def __init__(self, parent=None, title=None):
        super(PlotWidget, self).__init__(parent)

        self._rate = 10
        self._size = 10
        self._avg = 1
        self._avgdata = None
        self.curveA = None
        self.curveB = None
        self.curveC = None
        self._avgdata = None
        self._rxdelay_us = 0
        self._select_begin = 100
        self._select_end = 200

        self.createWidget(title)

    def createWidget(self, title=None):
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
        self.canvas = FigureCanvasQTAgg(figure)
        layout.addWidget(self.canvas)

        # create navigation toolbar, remove subpluts action
        self.toolbar = NavigationToolbar2QT(self.canvas, self, False)
        actions = self.toolbar.actions()
        self.toolbar.removeAction(actions[7])
        layout.addWidget(self.toolbar)

        # final layout
        self.frame.setLayout(layout)
        mainlayout.addWidget(self.frame)
        self.setLayout(mainlayout)

    def initPlot(self):
        pass

    def redraw(self):
        pass

    def setTitle(self, title):
        self.frame.setTitle(title)

    def setAverageCount(self, cnt):
        self._avg = max(cnt, 1)

    def setRate(self, rate):
        self._rate = int(rate)
        self.initPlot()

    def setSize(self, size):
        self._size = int(size)
        self.initPlot()

    def setSelection(self, begin_us, end_us):
        begin = int(begin_us * self._rate / 1E6)
        end = int(end_us * self._rate / 1E6)
        
        begin = max(begin, 1)
        end = max(end, begin)
        end = min(end, self._size)

        log.debug("Set selection [0, [%d, %d], %d]." % (begin, end, self._size))
        self._select_begin = begin
        self._select_end = end
        self.initPlot()

    def setRxDelay(self, us=None):
        if us is not None:
            self._rxdelay_us = us
        self.initPlot()

    def _get_rxdelay_samples(self):
        return int(self._rxdelay_us * self._rate / 1E6)

    def _get_rxdelay_us(self):
        return self._rxdelay_us

    def startTime(self):
        return self._get_rxdelay_us()

    def stopTime(self):
        return self.startTime() + (self._size - 0) * 1E6 / self._rate


class PlotTimeWidget(PlotWidget):
    def __init__(self, parent=None, title=None):
        super(PlotTimeWidget, self).__init__(parent)
        self._mode = 'A'
        self._phase = 0

        self.initPlot()
        # self.autoscale()

    def initPlot(self, rescale=True):
        super(PlotTimeWidget, self).initPlot()

        # configure time axis
        time = np.linspace(self.startTime(), self.stopTime(), self._size)
        # zeros = np.zeros(len(time))
        self._avgdata = np.zeros(len(time))

        # configure axis
        self.axis.clear()
        self.axis.grid()
        self.axis.set_xlabel('t [us]')

        start = self._select_begin
        stop = self._select_end
        self.curveA = self.axis.plot(time[0:start+1], self._avgdata[0:start+1], '0.50')[0]
        self.curveB = self.axis.plot(time[start:stop], self._avgdata[start:stop], 'b')[0]
        self.curveC = self.axis.plot(time[stop-1:], self._avgdata[stop-1:], '0.50')[0]

        self.autoscale()

    def autoscale(self):
        # x1, x2, y1, y2 = self.axis.axis()

        try:
            maxdata = max(self._avgdata)
        except TypeError:
            maxdata = 100
        if maxdata < 10:
            maxdata = 100

        x1 = self.startTime()
        x2 = self.stopTime()
        if self._mode in ('I', 'P'):
            y1 = maxdata * 1.1
            y2 = -maxdata * 1.1
        if self._mode == 'A':
            y1 = -maxdata * 0.1
            y2 = maxdata * 1.1
        log.debug(f'PlotTime.Autoscale xstart={x1}, xstop={x2}, ystart={y1}, ystop={y2}')
        self.axis.axis((x1, x2, y1, y2))

        self.redraw()

    def updatePlot(self, m: NMRMeasurement):
        if m.rate != self._rate:
            self.set_rate(m.rate)
        if m.size != self._size:
            self.set_size(m.size)

        # select the right data depending on the mode
        data = None
        if self._mode == 'A':  # Amplitude
            data = np.abs(m.iqdata)
        if self._mode == 'I':  # In-Phase
            data = m.iqdata.real
        if self._mode == 'P':  # Shift Phase
            # calc phase factors
            p_r = np.cos(self._phase * 2 * np.pi / 360)
            p_i = np.sin(self._phase * 2 * np.pi / 360)
            data = m.iqdata.real*p_r + m.iqdata.imag*p_i

        # stream through the averager
        if self._avgdata is None or (len(self._avgdata) != len(data)):
            self._avgdata = data
        self._avgdata = (self._avg - 1) * self._avgdata + data
        self._avgdata = self._avgdata / self._avg

        self.redraw()

    def redraw(self):
        super(PlotTimeWidget, self).redraw()

        # x1, x2, y1, y2 = self.axis.axis()
        start = self._select_begin
        stop = self._select_end
        self.curveA.set_ydata(self._avgdata[0:start+1])
        self.curveB.set_ydata(self._avgdata[start:stop])
        self.curveC.set_ydata(self._avgdata[stop-1:])
        self.canvas.draw()
        # self.axis.axis((x1, x2, y1, y2))

    def setMode(self, mode):
        if mode not in ['I', 'P', 'A']:
            ValueError("Invalid mode: %s" % (mode))
        self._mode = mode
        self._avgdata = None
        # self.initPlot()

    def setPhase(self, phase):
        if phase:
            phase = int(phase)
        if phase < 0 or phase > 359:
            ValueError("Invalid phase: %s" % (phase))
        self._phase = phase

    def getData(self):
        if(self._avgdata is None):
            raise ValueError("No measurement data present yet.")
        Xdata = np.linspace(self.startTime(), self.stopTime(), self._size)
        Ydata = self._avgdata
        return (Xdata, Ydata)


class PlotFFTWidget(PlotWidget):
    def __init__(self, parent=None, title=None):
        super(PlotFFTWidget, self).__init__(parent)

        self._freq_offset = 0

        self.initPlot()
        # self.autoscale()

    def initPlot(self):
        super(PlotFFTWidget, self).initPlot()

        size = self._size
        rate = self._rate
        start = self._select_begin
        stop = self._select_end
        # ignore = self._get_ignore_samples()

        fftsize = max(stop - start, 1)  # no zeroes here
        # log.debug("fftsize = stop - start = %d - %d = %d" % (start, stop, fftsize))

        freqs = (np.fft.fftshift(np.fft.fftfreq(fftsize, d=float(1 / rate))) +
                 self._freq_offset) / 1E6
        zeros = np.zeros(len(freqs))

        # store view
        x1, x2, y1, y2 = self.axis.axis()

        # configure axis
        self.axis.clear()
        self.axis.grid()
        self.curve = self.axis.plot(freqs, zeros, 'b')[0]


        # create vertical line
        vertlinepos = [self._freq_offset/1E6, self._freq_offset/1E6]
        self.vertLine = self.axis.plot(vertlinepos, [-100, 500], 'y--')[0]
        self.vertLine.set_color(color='r')
        self.vertLine.set_linestyle('--')
        self.vertLine.set_linewidth(2.0)

        self._avgdata = zeros

        self._freqs = freqs

        # restore view
        self.axis.axis((None, None, y1, y2))

    def autoscale(self, xstart=None, xstop=None, ystart=None, ystop=None):
        if xstart is None:
            xstart = min(self._freqs)
        if xstop is None:
            xstop = max(self._freqs)

        try:
            maxdata = max(self._avgdata)
        except TypeError:
            maxdata = 500

        if(maxdata < 50):
            maxdata = 500

        x1 = xstart
        x2 = xstop
        y1 = -maxdata * 0.1
        y2 = maxdata * 1.1

        log.debug(f'PlotFFT.Rescale x1={x1}, x2={x2}, y1={y1}, y2={y2}')
        self.axis.axis((x1, x2, y1, y2))
        self.axis.set_xlabel('F [MHz]')

    def updatePlot(self, m: NMRMeasurement):
        if m.rate != self._rate:
            self.set_rate(m.rate)
        if m.size != self._size:
            self.set_size(m.size)

        # create FFT
        # ignore = self._get_ignore_samples()
        start = self._select_begin
        stop = self._select_end
        fft = np.abs(np.fft.fftshift(np.fft.fft(m.iqdata[start:stop],
                     norm='ortho')))

        # stream through the averager
        if self._avgdata is None:
            self._avgdata = fft
        self._avgdata = (self._avg - 1) * self._avgdata + fft
        self._avgdata = self._avgdata / self._avg

        # plot zeros and store the returned Line2D object
        self.curve.set_ydata(self._avgdata)
        self.canvas.draw()

    def setFrequencyOffset(self, freq):
        self._freq_offset = freq
        self.initPlot()

    def getData(self):
        if(self._avgdata is None):
            raise ValueError("No measurement data present yet.")
        Xdata = self._freqs
        Ydata = self._avgdata
        return (Xdata, Ydata)
