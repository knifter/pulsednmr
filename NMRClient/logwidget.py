
import logging
from logutil import DefaultFormatter
pyqt = 5
if pyqt == 4:
    import PyQt4.QtGui as qt
    import PyQt4.QtCore as qtcore
if pyqt == 5:
    from PyQt5.QtCore import Qt
    from PyQt5.QtWidgets import QWidget, QGridLayout, QGroupBox, QListWidget
    from PyQt5.QtGui import QFont

MAX_LINES = 30

class LogWidget(QWidget):
    def __init__(self, parent=None, logname=None, title=None, level=logging.DEBUG, formatter=DefaultFormatter()):
        super(LogWidget, self).__init__(parent)

        # Layout
        mainlayout = QGridLayout()
        # mainlayout.setMargin(0)
        layout = QGridLayout()

        # title
        self.frame = QGroupBox()
        if(title):
            self.frame.setTitle(title)
        
        # UI
        # layout.setMargin(0)
        self.list = QListWidget(self)
        self.list.setHorizontalScrollBarPolicy(Qt.ScrollBarAlwaysOff)
        self.list.setFont(QFont("Monospace"))
        layout.addWidget(self.list)

        # Log
        self.level = level
        self.format = formatter
        self.handler = WidgetLogHandler(self)
        self.handler.setFormatter(self.format)

        if logname != None:
            self.setLogName(logname)

        self.frame.setLayout(layout)
        mainlayout.addWidget(self.frame)
        self.setLayout(mainlayout)

    def setTitle(self, title):
        self.frame.setTitle(title)

    def setLogLevel(self, level):
        self.handler.setLevel(level)

    def setLogName(self, name):
        self.log = logging.getLogger(name)
        self.log.setLevel(self.level)
        self.log.addHandler(self.handler)

    def addLine(self, line):
        # lastrow = self.list.indexAt(QPoint(5, self.list.height() - 10)).row()
        # scroll = 0
        # print "lastrow: %d, count: %d" % (lastrow, self.list.count())
        # if lastrow == self.list.count():
        #     scroll = 1
        self.list.addItem(line)
        self.list.scrollToBottom()
        if self.list.count() > MAX_LINES:
            self.list.takeItem(0)

    def clear(self):
        self.list.clear()

class WidgetLogHandler(logging.Handler):
    def __init__(self, parent=None):
        self._parent = parent
        super(WidgetLogHandler, self).__init__()

    @property
    def parent(self):
        return self._parent

    def emit(self, record):
        msg = self.format(record)
        self.parent.addLine(msg)


### TEST #######
def test():
    a = qt.QApplication([])
    l = LogWidget("test")
    l.show()
    l.setLogLevel(logging.DEBUG)

    log = logging.getLogger("test.test1")
    log.debug("debug message")
    log.info("info message")
    log.fatal("fatal message")
    for i in range(15):
        log.info("Item %d", i)
    a.exec_()

if __name__ == '__main__':
    test() 
