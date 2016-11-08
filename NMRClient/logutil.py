import logging

class DelayedHandler(logging.Handler):
    def __init__(self, parent=None):
        self._parent = parent
        super(DelayedHandler, self).__init__()
        self._records = []
        # self.setFormatter(logging.Formatter("%(message)s"))

    @property
    def parent(self):
        return self._parent

    def emit(self, record):
        self._records.append(record)

    def take_records(self):
        records = self._records
        self._records = []
        return records


class LevelFormatter(logging.Formatter):
    _levels = ['DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL', 'FATAL']
    def __init__(self):
        super(LevelFormatter, self).__init__()
        self._prefix = str()
        self._level_prefix = dict({
        'DEBUG'     : "(  ) ",
        'INFO'      : "(--) ",
        'WARNING'   : "(ww) ",
        'ERROR'     : "(ee) ",
        'CRITICAL'  : "(EE) ",
        'FATAL'     : "*FF* "
        })
        self._level_format = dict()
        for level in self._levels:
            self._level_format[level] = "%(message)s"

    def set_prefix(self, prefix):
        self._prefix = prefix

    def set_level_format(self, level, fmt):
        self._level_format[level] = fmt

    def set_level_prefix(self, level, prefix):
        self._level_prefix[level] = prefix

    def format(self, record):
        # Replace the original format with one customized by logging level
        # if record.levelname in self._formats.keys():
        level = record.levelname
        self._fmt = self._prefix + self._level_prefix[level] + self._level_format[level]

        # Call the original formatter class to do the grunt work
        return super(LevelFormatter, self).format(record)

class DefaultFormatter(LevelFormatter):
    def __init__(self):
        super(DefaultFormatter, self).__init__()
        self.set_level_format('DEBUG', '%(name)s %(filename)s(%(lineno)d).%(funcName)s: %(message)s')
        self.set_level_format('INFO', '%(message)s')
        self.set_level_format('WARNING', '%(name)s: %(message)s at %(filename)s(%(lineno)d)')
        self.set_level_format('ERROR', '%(name)s: %(message)s')
        self.set_level_format('CRITICAL', '%(name)s: %(filename)s(%(lineno)d): %(message)s')
        self.set_level_format('FATAL', '%(name)s: %(filename)s(%(lineno)d): %(message)s')

class LogFileFormatter(DefaultFormatter):
    def __init__(self):
        super(LogFileFormatter, self).__init__()
        self.set_prefix("%(asctime).19s ")

def RemoveRootHandlers():
    root = logging.getLogger()
    if root.handlers:
        for handler in root.handlers:
            root.removeHandler(handler)

def AddLogHandler(name, loglevel, filename=None, formatter=DefaultFormatter()):
    log = logging.getLogger(name)
    if log.level == 0 or log.level > loglevel:
        log.setLevel(loglevel)
    if filename:
        h = logging.FileHandler(filename)
    else:
        h = logging.StreamHandler()
    h.setLevel(loglevel)
    h.setFormatter(formatter)
    log.addHandler(h)

### TEST #######
def test():
    AddLogHandler("test", logging.DEBUG)

    log = logging.getLogger("test.test1")
    log.debug("debug message")
    log.info("info message")
    log.fatal("fatal message")
    for i in range(15):
        log.info("Item %d", i)

if __name__ == '__main__':
    test() 
