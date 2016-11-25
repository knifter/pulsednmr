
from PyQt5.QtCore import QTimer
# from PyQt5.QtNetwork import QAbstractSocket, QTcpSocket
from PyQt5.QtWidgets import QApplication, QMainWindow, QMessageBox
from PyQt5.uic import loadUi

import logging

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

        # create timer for the repetitions
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.fireTimer)

        self.plotTimeWidget.set_ignore(samples=RXTX_OFFSET)
        self.plotFFTWidget.set_ignore(samples=RXTX_OFFSET)

    def setDefaults(self):
        self.deltaValue.setValue(300)
        self.rateValue.setCurrentIndex(4)
        self.rxTimeValue.setValue(2.0)
        self.averageValue.setValue(5)
        self.averageCheck.setChecked(False)

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
        self.nmr.fire()
        if self.plotTimeCheck.isChecked():
            self.plotTimeWidget.updatePlot(self.nmr.measurement)
        if self.plotFFTCheck.isChecked():
            self.plotFFTWidget.updatePlot(self.nmr.measurement)

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
        except TimeoutError:
            self.status("Timeout connecting to %s" % host)
        except NMRConnectionError as e:
            self.status("Connection Error: " + repr(e))
        if self.nmr.connected:
            self.logWidget.clear()
            self.status("Connected to %s:%d" % (host, port))
            self.setWindowTitle(WINDOW_TITLE + " (%s)" % (host))
            self._mode_1()
        else:
            self._mode_not_connected()
            self.action_Connect()

    def disconnect(self):
        self.client.disconnect()
        self._mode_not_connected()

    def status(self, message, timeout=3000):
        if message == None:
            self.statusBar.clearMessage()
        else:
            self.statusBar.showMessage(message, timeout)
            log.info(message)

    ### (UI) ACTIONS ########################################################################
    def set_freq(self, value):
        hz = int(value * 1E6)
        self.nmr.set_freq(hz)
        self.plotFFTWidget.set_frequencyOffset(hz)

    def set_rate(self, index):
        self.nmr.set_rate(index=index)
        rate = self.nmr.rate
        size = int(self.rxTimeValue.value() * rate / 1E3);
        log.debug("rate = %d, new size = %d" % (rate, size))

        self.plotTimeWidget.set_rate(rate)
        self.plotFFTWidget.set_rate(rate)

        self.set_rxSize(size)

    def set_rxTime(self, time):
        size = int(time * self.nmr.rate / 1E3)

        self.set_rxSize(size)

    def set_rxSize(self, size):
        self.nmr.set_rxsize(size)

        self.plotTimeWidget.set_size(size)
        self.plotFFTWidget.set_size(size)
        self.rxSamplesEdit.setText(str(size))

    def set_awidth(self, width_us):
        self.nmr.set_awidth(width_us)
        self.plotTimeWidget.set_ignore(us=width_us)
        self.plotFFTWidget.set_ignore(us=width_us)

    def set_bwidth(self, width_us):
        self.nmr.set_bwidth(width_us)

    def set_abdelay(self, delay_ms):
        self.nmr.set_abdelay(1000 * delay_ms)

    def set_bbdelay(self, delay_ms):
        self.nmr.set_bbdelay(1000 * delay_ms)

    def set_bcount(self, cnt):
        self.nmr.set_bcount(cnt)

    def set_delta(self, ms):
        if self.started:
            self.timer.stop()
            self.timer.start(ms)

    def set_average(self, value = None):
        if not self.averageCheck.isChecked():
            self.plotTimeWidget.setAverageCount(1)
            self.plotFFTWidget.setAverageCount(1)
            return
        self.plotTimeWidget.setAverageCount(self.averageValue.value())
        self.plotFFTWidget.setAverageCount(self.averageValue.value())

    def action_plotTimeFFTCheck(self):
        self.plotTimeWidget.setVisible(self.plotTimeCheck.isChecked())
        self.plotFFTWidget.setVisible(self.plotFFTCheck.isChecked())

    def action_plotTimeModeDrop(self, index):
        if index == 0:
            self.plotTimeWidget.set_mode('A')
        if index == 1:
            self.plotTimeWidget.set_mode('I')
        if index == 2:
            self.plotTimeWidget.set_mode('IQ')

    ### (Menu) ACTIONS ########################################################################
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

    ### Interface Modes #######################################################################
    def _mode_not_connected(self):
        self.controlWidget.setDisabled(True)
        self.stopTimer()

    def _mode_0(self):
        self.controlWidget.setDisabled(False)
        #self.mode0Group.setVisible(True)
        #self.mode1Group.setDisabled(True)
        #self.mode2Group.setVisible(False)

    def _mode_1(self):
        self.controlWidget.setDisabled(False)
        #self.mode0Group.setVisible(False)
        #self.mode1Group.setDisabled(False)
        #self.mode2Group.setVisible(False)

    def _mode_2(self):
        self.controlWidget.setDisabled(False)
        #self.mode0Group.setVisible(False)
        #self.mode1Group.setDisabled(False)
        #self.mode2Group.setVisible(True)
