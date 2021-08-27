import PyQt5.QtGui

QT_VERSION = 5
if QT_VERSION == 4:
    from PyQt4.QtCore import QSize, QUrl
    from PyQt4.QtGui import QSpinBox, QDialog, QFormLayout, QComboBox, QDialogButtonBox, QSizePolicy
    # QRegExpValidator?
if QT_VERSION == 5:
    from PyQt5.QtCore import QSize, QUrl, QRegExp
    from PyQt5.QtWidgets import QSpinBox, QDialog, QFormLayout, QComboBox, QDialogButtonBox, QSizePolicy
    from PyQt5.QtGui import QRegExpValidator

DEFAULT_HOST = "192.168.137.100"
DEFAULT_PORT = 1001

class ConnectDialog(QDialog):
    def __init__(self, parent=None, default_host=DEFAULT_HOST, default_port=DEFAULT_PORT):
        super(ConnectDialog, self).__init__(parent)
        self.url = QUrl()

        self._default_host = default_host
        self._default_port = default_port

        self.setWindowTitle("Connect to Server")
        self.setModal(True)
        self.setMinimumSize(QSize(500, 100))
        self.setLayout(QFormLayout())
        # self.layout().setSizePolicy(qt.QSizePolicy(qt.QSizePolicy.Expanding, qt.QSizePolicy.Expanding))

        self.hostEdit = QComboBox()
        self.hostEdit.setSizePolicy(QSizePolicy(QSizePolicy.Expanding, QSizePolicy.Preferred))
        self.hostEdit.setEditable(True)
        self.hostEdit.lineEdit().selectAll()
        self.layout().addRow("Host:", self.hostEdit)

        self.portSpin = QSpinBox()
        self.portSpin.setMaximum(65353)
        self.portSpin.setValue(self._default_port)
        self.layout().addRow("Port:", self.portSpin)

        buttons = QDialogButtonBox(QDialogButtonBox.Ok | QDialogButtonBox.Cancel)
        buttons.accepted.connect(lambda: self.done(True))
        buttons.rejected.connect(lambda: self.done(False))
        self.layout().addWidget(buttons)
        self.adjustSize()
        self.show()

        # IP address validator
        rx = QRegExp(
            '^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$')
        # self.addrValue.setValidator(QRegExpValidator(rx, self.addrValue))

    def exec_(self):
        if self.hostEdit.count() < 1:
            self._set_default()
        return super(ConnectDialog, self).exec_()

    def _set_default(self):
        if self._default_host:
            self.hostEdit.addItems([self._default_host])
            self.hostEdit.lineEdit().selectAll()
        if self._default_port:
            self.portSpin.setValue(self._default_port)
        self._set_url()

    def _set_url(self):
        self.url.setUrl("pymot://" + self.hostEdit.currentText())

    def add_url(self, urlstr):
        url = QUrl(urlstr)
        self.hostEdit.addItem(str(url.host()) + ":" + str(url.port()))

    @property
    def host(self):
        self._set_url()
        return str(self.url.host())

    @property
    def port(self):
        self._set_url()
        return int(self.url.port(self.portSpin.value()))
