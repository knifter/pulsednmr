
from PyQt5.QtCore import QTimer, Qt
# from PyQt5.QtNetwork import QAbstractSocket, QTcpSocket
from PyQt5.QtWidgets import QApplication, QMainWindow, QMessageBox, QFileDialog
from PyQt5.uic import loadUi
from PyQt5.QtGui import QPalette

import logging
import datetime

from connectdialog import ConnectDialog
from nmrctrl import NMRConnectionError, RATES


LOG_ROOT = 'nmr'
LOG_NAME = 'nmr.gui'
WINDOW_TITLE = "NMR Control"
RXTX_OFFSET = 85

log = logging.getLogger(LOG_NAME)

class MainWindow(QMainWindow):
    def __init__(self, app: QApplication):
        super(MainWindow, self).__init__(None)

        self.application = app
        self._log = None
        self._lastTimeDataFilename = None
        self._lastFFTDataFilename = None

        self.createForm()
        self.setDefaults()

        # configure interface mode: not yet connected
        self._mode_not_connected()

    def createForm(self):
        loadUi("mainwindow.ui", self)

        # Plot Widget

        # LogWidget
        self.logWidget.setLogName(LOG_ROOT)
        self.logWidget.setTitle("log")
        self.splitter.addWidget(self.logWidget)

        self.splitter.setCollapsible(2, True)
        # self.splitter.setSizes([10, 0, 90])

        self.rateValue.addItems(["%.0fK" % (r/1000) for r in RATES.values()])

        # state variable
        self.started = False

        ### connect signals from buttons and boxes
        # Acquisition
        self.deltaValue.valueChanged.connect(self.set_delta)
        self.rateValue.currentIndexChanged.connect(self.set_rate)
        self.rxTimeValue.valueChanged.connect(self.set_rxTime)
        self.averageValue.valueChanged.connect(self.set_average)
        self.averageCheck.stateChanged.connect(self.set_average)
        self.rxDelayCheck.stateChanged.connect(self.set_rxDelay)
        self.rxDelayValue.valueChanged.connect(self.set_rxDelay)
        # Mode 0
        self.plotTimeCheck.stateChanged.connect(self.action_plotTimeFFTCheck)
        self.plotFFTCheck.stateChanged.connect(self.action_plotTimeFFTCheck)
        self.plotTimeModeDrop.currentIndexChanged.connect(self.action_plotTimeModeDrop)
        # Mode 1
        self.freqValue.valueChanged.connect(self.set_freq)
        self.awidthValue.valueChanged.connect(self.set_awidth)
        # Mode 2
        self.bwidthValue.valueChanged.connect(self.set_bwidth)
        self.abdelayValue.valueChanged.connect(self.set_abdelay)
        self.bbdelayValue.valueChanged.connect(self.set_bbdelay)
        self.bcountValue.valueChanged.connect(self.set_bcount)

        # Other
        self.menuConnect.triggered.connect(self.action_Connect)
        self.startButton.clicked.connect(self.startButtonClicked)
        self.menuExit.triggered.connect(self.close)
        self.menuExportTimeData.triggered.connect(self.action_ExportTimeData)
        self.menuExportFreqData.triggered.connect(self.action_ExportFreqData)

        # create timer for the repetitions
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.fireTimer)

        self.plotTimeWidget.setIgnore(samples=RXTX_OFFSET)
        self.plotFFTWidget.setIgnore(samples=RXTX_OFFSET)

    def setDefaults(self):
        self.deltaValue.setValue(300)
        self.rateValue.setCurrentIndex(4)
        self.rxTimeValue.setValue(2.0)
        self.averageValue.setValue(5)
        self.averageCheck.setChecked(False)
        self.rxDelayValue.setValue(0)
        self.rxDelayCheck.setChecked(False)

        self.freqValue.setValue(22)
        self.awidthValue.setValue(12)

        self.bwidthValue.setValue(12)
        self.abdelayValue.setValue(1)
        self.bbdelayValue.setValue(1)
        self.bcountValue.setValue(0)

        self.plotFFTCheck.setChecked(True)
        self.plotTimeCheck.setChecked(True)
        self.plotTimeModeDrop.setCurrentIndex(0)

    @property
    def nmr(self):
        return self.application.nmr

    ### Start/Stop Meganism
    def startButtonClicked(self):
        if not self.started:
            self.startTimer()
        else:
            self.stopTimer()

    def startTimer(self):
        self.fireTimer()
        self.timer.start(self.deltaValue.value())
        self.startButton.setText('Stop')
        self.started = True

    def fireTimer(self):
        try:
            self.nmr.fire()
            if self.plotTimeCheck.isChecked():
                self.plotTimeWidget.updatePlot(self.nmr.measurement)
            if self.plotFFTCheck.isChecked():
                self.plotFFTWidget.updatePlot(self.nmr.measurement)
        except (ConnectionAbortedError, ConnectionError):
            self.disconnect()

    def stopTimer(self):
        self.timer.stop()
        self.startButton.setText('Start')

        self.started = False

    # def display_error(self, socketError):
    #     if socketError == QAbstractSocket.RemoteHostClosedError:
    #         pass
    #     else:
    #         QMessageBox.information(self, 'PulsedNMR', 'Error: %s.' % self.socket.errorString())
    #     self.startButton.setText('Start')
    #     self.startButton.setEnabled(True)

    def connect(self, host = None, port = None):
        try:
            self.nmr.connect(host, port)
            # self.config.add_connection(host=host, port=port)
        except TimeoutError as e:
            self.status("Timeout connecting to %s" % host)
        except NMRConnectionError as e:
            self.status("Connection Error: " + repr(e))

        if self.nmr.connected:
            self.logWidget.clear()
            self.status("Connected to %s:%d" % (host, port))
            self.setWindowTitle(WINDOW_TITLE + " (%s)" % (host))
            self._mode_connected()
        else:
            self._mode_not_connected()
            self.action_Connect()

    def disconnect(self):
        try:
            self.nmr.disconnect()
        except:
            pass
        self._mode_not_connected()
        self.setWindowTitle(WINDOW_TITLE)
        self.status("Disconnected.")

    def status(self, message, timeout=3000):
        if message == None:
            self.statusBar.clearMessage()
        else:
            self.statusBar.showMessage(message, timeout)
            log.info(message)

    ### (UI) ACTIONS ########################################################################
    def set_freq(self, value):
        hz = int(value * 1E6)
        self.checkInputs()
        self.nmr.set_freq(hz)
        self.plotFFTWidget.setFrequencyOffset(hz)

    def set_rate(self, index):
        self.checkInputs()
        self.nmr.set_rate(index=index)
        rate = self.nmr.rate
        size = int(self.rxTimeValue.value() * rate / 1E3);
        log.debug("rate = %d, new size = %d" % (rate, size))

        self.plotTimeWidget.setRate(rate)
        self.plotFFTWidget.setRate(rate)

        self.set_rxSize(size)
        self.set_rxDelay()

    def set_rxTime(self, time):
        self.checkInputs()
        size = int(time * self.nmr.rate / 1E3)

        self.set_rxSize(size)

    def set_rxSize(self, size):
        self.checkInputs()
        self.nmr.set_rxsize(size)

        self.plotTimeWidget.setSize(size)
        self.plotFFTWidget.setSize(size)
        self.rxSamplesEdit.setText(str(size))

    def set_awidth(self, width_us):
        self.checkInputs()
        self.nmr.set_awidth(width_us)
        self.plotTimeWidget.setIgnore(us=width_us)
        self.plotFFTWidget.setIgnore(us=width_us)

    def set_bwidth(self, width_us):
        self.checkInputs()
        self.nmr.set_bwidth(width_us)

    def set_abdelay(self, delay_ms):
        self.checkInputs()
        self.nmr.set_abdelay(1000 * delay_ms)

    def set_bbdelay(self, delay_ms):
        self.checkInputs()
        self.nmr.set_bbdelay(1000 * delay_ms)

    def set_bcount(self, cnt):
        self.checkInputs()
        self.nmr.set_bcount(cnt)

    def set_delta(self, ms):
        self.checkInputs()
        if self.started:
            self.timer.stop()
            self.timer.start(ms)

    def set_average(self, value = None):
        self.checkInputs()
        if not self.averageCheck.isChecked():
            self.plotTimeWidget.setAverageCount(1)
            self.plotFFTWidget.setAverageCount(1)
            return
        self.plotTimeWidget.setAverageCount(self.averageValue.value())
        self.plotFFTWidget.setAverageCount(self.averageValue.value())

    def set_rxDelay(self, value = None):
        self.checkInputs()
        usecs = self.rxDelayValue.value() * 1000
        if not self.rxDelayCheck.isChecked():
            usecs = 0
        self.nmr.set_rxdelay(usecs)
        self.plotTimeWidget.setRxDelay(usecs)
        self.plotFFTWidget.setRxDelay(usecs)

    def checkInputs(self):
        # find values, all in us
        awidth = self.awidthValue.value()
        bwidth = self.awidthValue.value()
        aadelay = self.deltaValue.value()*1E3
        abdelay = self.abdelayValue.value()*1E3
        bbdelay = self.bbdelayValue.value()*1E3
        bcount = self.bcountValue.value()
        rxdelay = self.rxDelayValue.value()*1E3*self.rxDelayCheck.isChecked()
        rxtime = self.rxTimeValue.value()*1E3

        if bcount == 0:
            pulses_len = awidth
        else:
            pulses_len = abdelay + bbdelay*(bcount - 1) + bwidth
        acq_len = rxdelay + rxtime
        cycle_len = max(pulses_len, acq_len)

        # print("pulses %d us" % pulses_len)
        # print("acq    %d us" % acq_len)

        # A-to-A Delay should be more as the total pulse length
        if cycle_len > aadelay:
            setColor(self.deltaValue, 'rd')
        else:
            setColor(self.deltaValue, 'bl')

        # Alen < A-B-Delay
        if awidth > abdelay:
            setColor(self.awidthValue, 'rd')
            setColor(self.abdelayValue, 'rd')
        else:
            setColor(self.awidthValue, 'bl')
            setColor(self.abdelayValue, 'bl')

        # Blen < B-B Delay
        if bwidth > bbdelay:
            setColor(self.bwidthValue, 'rd')
            setColor(self.bbdelayValue, 'rd')
        else:
            setColor(self.bwidthValue, 'bl')
            setColor(self.bbdelayValue, 'bl')

        # disable B boxes when bcount < 1
        ben = (bcount != 0)
        self.abdelayValue.setEnabled(ben)
        self.bwidthValue.setEnabled(ben)
        self.bbdelayValue.setEnabled(ben)

    ### (Menu) ACTIONS ########################################################################
    def action_plotTimeFFTCheck(self):
        self.plotTimeWidget.setVisible(self.plotTimeCheck.isChecked())
        self.plotFFTWidget.setVisible(self.plotFFTCheck.isChecked())

    def action_plotTimeModeDrop(self, index):
        if index == 0:
            self.plotTimeWidget.setMode('A')
        if index == 1:
            self.plotTimeWidget.setMode('I')
        if index == 2:
            self.plotTimeWidget.setMode('Q')

    def action_Connect(self):
        # open pop-up
        dialog = ConnectDialog()
        # for con in self.config.connections():
        #     dialog.add_url(con.url)
        r = dialog.exec_()
        if r:
            self.connect(dialog.host, dialog.port)
        if not self.nmr.connected:
            self._mode_not_connected()
        dialog.close()

    def action_Disconnect(self):
        self.disconnect()

    def action_ExportTimeData(self):
        (Xdata, Ydata) = self.plotTimeWidget.getData()
        if len(Xdata) != len(Ydata):
            raise ValueError("X and Y Dimensions do not agree.")
        (filename, selectedFilter) = QFileDialog.getSaveFileName(self, "Save CSV", self._lastTimeDataFilename, "CSV-files (*.csv)");
        if filename == '' or filename is None:
            return

        # Save header
        f = open(filename, "w")
        f.write("# NMR Time Data Export\n")
        f.write("# Date: %s\n" % str(datetime.datetime.now()))
        f.write("# A-Width: %d us\n" % self.nmr.awidth)
        f.write("# B-Width: %d us\n" % self.nmr.bwidth)
        f.write("# A-to-A-Delay: %d ms\n" % self.deltaValue.value())
        f.write("# A-to-B Delay: %d ms\n" % (self.nmr.abdelay / 1000))
        f.write("# B-to-B Delay: %d ms\n" % (self.nmr.bbdelay / 1000))
        f.write("# B Count: %d\n" % self.nmr.bcount)
        f.write("\n# Data: Time, Value\n")
        for xval, yval in zip(Xdata, Ydata):
            f.write("%2.6f, %1.6f\n" %(xval, yval))
        f.close()

        self.status("Time Data exproted to %s" % (filename))
        self._lastTimeDataFilename = filename

    def action_ExportFreqData(self):
        (Xdata, Ydata) = self.plotFFTWidget.getData()
        if len(Xdata) != len(Ydata):
            raise ValueError("X and Y Dimensions do not agree.")
        (filename, selectedFilter) = QFileDialog.getSaveFileName(self, "Save CSV", self._lastFFTDataFilename, "CSV-files (*.csv)");
        if filename == '' or filename is None:
            return

        # Save header
        f = open(filename, "w")
        f.write("# NMR Frequency Data Export\n")
        f.write("# Date: %s\n" % str(datetime.datetime.now()))
        f.write("# A-Width: %d us\n" % self.nmr.awidth)
        f.write("# B-Width: %d us\n" % self.nmr.bwidth)
        f.write("# A-to-A-Delay: %d ms\n" % self.deltaValue.value())
        f.write("# A-to-B Delay: %d ms\n" % (self.nmr.abdelay / 1000))
        f.write("# B-to-B Delay: %d ms\n" % (self.nmr.bbdelay / 1000))
        f.write("# B Count: %d\n" % self.nmr.bcount)
        f.write("\n# Data: Time, Value\n")
        for xval, yval in zip(Xdata, Ydata):
            f.write("%2.6f, %1.6f\n" %(xval, yval))
        f.close()

        self.status("Time Data exproted to %s" % (filename))
        self._lastFFTDataFilename = filename

    ### Interface Modes #######################################################################
    def _mode_not_connected(self):
        self.controlWidget.setDisabled(True)
        self.stopTimer()
        self.startButton.setEnabled(False)

    def _mode_connected(self):
        self.controlWidget.setDisabled(False)
        self.startButton.setEnabled(True)

def setColor(widget, color = 'bl'):
    pal = widget.palette()
    if color == 'rd':
        pal.setColor(QPalette.Text, Qt.red)
    if color == 'bl':
        pal.setColor(QPalette.Text, Qt.black)
    widget.setPalette(pal)
