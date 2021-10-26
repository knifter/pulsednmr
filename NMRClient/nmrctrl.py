import logging
import sys
import struct
from enum import Enum, unique
import socket
import numpy as np

DEFAULT_PORT = 1001
LOG_NAME = 'nmr.ctrl'

log = logging.getLogger(LOG_NAME)

def main():
    print("Start.")
    nmr = NMRCtrl()
    nmr.connect("nmr")
    nmr.set_rate(25E5)
    nmr.set_freq(22E6)
    nmr.set_awidth(200)
    nmr.set_bcount(0)
    nmr.set_rxsize(20);

    print("Fire.")
    i = 1
    while(i):
        nmr.fire()
        i -= 1
    nmr.disconnect()

@unique
class Command(Enum):
    SET_FREQ = 0
    SET_RATE = 1
    SET_AWIDTH = 2
    FIRE = 3
    SET_RX_SIZE = 4
    SET_AADELAY = 5 # currently host side, not implemented in PL
    SET_ABDELAY = 6
    SET_BWIDTH = 7
    SET_BBDELAY = 8
    SET_BCOUNT = 9
    SET_RX_DELAY = 10
    KEEPALIVE = 11
    SET_POWER = 12
    SET_BLANKLEN = 13
    SET_AMP = 14

NMR_CORE_CLK = 142857132 # Hz of the Core clock (~143 MHz)
NMR_PG_CLK = float(NMR_CORE_CLK) / 14 # Hz of the PulseGen Counter

RATES = {0: 25.0e3,   # 25ksmps
         1: 50.0e3,
         2: 125.0e3,
         3: 250.0e3,
         4: 500.0e3,
         5: 1250.0e3,
         6: 2500.0e3} # 2500ksmps

class NMRMeasurement(object):
    def __init__(self):
        self.freq = None
        self.rate = None
        self.awidth = None
        self.size = None
        self.iqdata = None

class NMRCtrl(object):
    def __init__(self):
        super(NMRCtrl, self).__init__()
        self._freq = 21E6
        self._rate_index = 6
        self._rate = RATES[self._rate_index]
        self._power = 0
        self._awidth = 10
        self._bwidth = 10
        self._abdelay = 1000
        self._bbdelay = 1000
        self._bcount = 0
        self._rxsize = 1000
        self._rxdelay = 0
        self._amp = False
        self._connected = False
        self._host = None
        self._port = None
        self._sequence = 0
        self._needs_config = True
        self._measurement = None
        self._socket = None

        # create TCP socket (Qt)
        #        self.socket = QTcpSocket(self)
        #        self.socket.connected.connect(self.connected)
        #        self.socket.readyRead.connect(self.read_data)
        #        self.socket.error.connect(self.display_error)

    def connect(self, host:str, port:int=DEFAULT_PORT):
        try:
            # create TCP socket
            self._socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self._socket.settimeout(2)
            self._socket.connect((host, port))
        except OSError as e:
            raise NMRConnectionError("Could not connect to %s?%s (%s)." % (host, port, repr(e)))

        # try a packet
        # try:
        #     self._send_cmd(Command.KEEPALIVE, tryconnection=True)
        # except TimeoutError:
        #     log.info("Connection failed. Server not responding. Busy?")
        #     return

        # Ok, connected
        self._host = host
        self._port = port
        self._connected = True
        try:
            self.configure()
        except TimeoutError:
            log.info("Connection failed. Server not responding. Busy?")
            self._socket = None
            self._connected = False
            return
        log.info("Connected to %s:%d" % (host, port))
        # raise ConnectionError("Socket error: %s" % self._socket.errorString())

    def disconnect(self):
        if(not self._connected):
            log.warning("Warning: Not connected on disconnect")
        else:
            self._socket.close()
            log.info("Disconnected from %s:%d" % (self._host, self._port))
        self._connected = False

    def configure(self):
        self.set_freq()
        self.set_power()
        self.set_awidth()
        self.set_rate()
        self.set_rxsize()
        self.set_bwidth()
        self.set_abdelay()
        self.set_bbdelay()
        self.set_bcount()
        self.set_rxdelay()

    def fire(self):
        # fire
        reply = self._send_cmd(Command.FIRE)

        # make measure
        m = NMRMeasurement()
        m.freq = self.freq
        m.rate = self.rate
        m.awidth = self.awidth
        m.size = self.rxsize

        # ydata = np.abs( self.data.astype(np.float32).view(np.complex64) [0::2] / (1 << 30) )
        buffer = reply.data;
        data = np.frombuffer(buffer, np.int32)
        m.iqdata = np.frombuffer(reply.data, np.int32).astype(np.float32).view(np.complex64) / (1 << 30)
        # print(m.iqdata);
        self._measurement = m;
        return m;
    
    @property
    def measurement(self):
        if(self._measurement == None):
            raise NMRNoDataError("No measurement obtained yet.");
        return self._measurement

    def _send_cmd(self, cmd, param = 0, tryconnection=False):
        if not self._connected and not tryconnection:
            raise ConnectionError("Not connected.");
        if not isinstance(cmd, Command):
            raise ValueError("Invalid command: %s" % repr(cmd))
        param = int(param)
        if(param > (1<<28-1)):
            raise ValueError("Command parameter too big: %d" % param)

        # send command
        # id(uint32_t), cmd(uint32_t), param(uint32_t), data_len(uint32_t)
        self._sequence += 1
        command_bin = struct.pack('<IIII', self._sequence, cmd.value, param, 0)
        # log.debug("Send:\tCommand(id=%d, len = %d)" % (self._sequence, len(command_bin)))
        self._socket.sendall(command_bin)

        # receive reply
        # id(uint32_t), result(uint32_t), data_len(uint32_t)
        reply = CommandReply()
        try:
            reply_bin = self._socket.recv(12)
        except socket.timeout:
            raise TimeoutError("Timeout while receiving data.")
        if(len(reply_bin) != 12):
            raise ConnectionError("Did not receive a complete reply header. (received len = %d)" % len(reply_bin));
        (reply.id, reply.resultcode, reply.data_len) = struct.unpack('<III', reply_bin)
        if(reply.id != self._sequence):
            raise ConnectionError("Reply sequence does not match request sequence. Out of sync!")
        if(reply.resultcode != 0):
            raise ConnectionError("Result = %d != OK" % reply.resultcode)
        if(reply.data_len):
            bread = 0
            reply.data = bytearray()
            while (bread < reply.data_len):
                buf = self._socket.recv(reply.data_len - bread)
                reply.data += buf
                bread += len(buf)
        # log.debug("\t\t" + repr(reply));
        return reply

    @property
    def connected(self):
        return self._connected

    @property
    def freq(self): return self._freq
    def set_freq(self, hz = None):
        if hz != None:
            self._freq = hz
        log.debug("Set frequency %d" % (self._freq))
        if self._connected:
            self._send_cmd(Command.SET_FREQ, int(self._freq))

    @property
    def rate(self): return self._rate
    def set_rate(self, rate = None, index = None):
        # print(f"set_rate({rate}, {index})");
        if index != None:
            # log.debug("Index %d: %d" % index, RATES[index])
            # RATES[index] # check that it is valid
            self._rate_index = index
        if rate != None:
            index = list(RATES.values()).index(rate)
            log.debug("Index of %d: %d" % (rate, index))
            self._rate_index = index

        log.debug("Set rate index %d (%d smps)" % (self._rate_index, RATES[self._rate_index]))
        self._rate = RATES[self._rate_index]
        if self._connected:
            self._send_cmd(Command.SET_RATE, self._rate_index)

    @property
    def power(self): return self._power
    def set_power(self, dbm = None):
        if dbm != None:
            self._power = dbm

        factor = min(3300*(self._power + 10), 65535);
        log.debug("Set power %d dBm, f = %d" % (self._power, factor))
        if self._connected:
            self._send_cmd(Command.SET_POWER, int(factor))

    @property
    def awidth(self): return self._awidth
    def set_awidth(self, usecs = None):
        if usecs != None:
            log.debug("Set A-Width %d us." % (usecs))
            self._awidth = usecs
        if self._connected:
            # clks = int(self._awidth * NMR_PG_CLK / 1E6 + 0.5)
            # print("A-width: %f us = %d clks, real time = %.8f" % (self._awidth, clks, clks / NMR_PG_CLK))
            self._send_cmd(Command.SET_AWIDTH, self._awidth)

    @property
    def bwidth(self): return self._bwidth
    def set_bwidth(self, usecs = None):
        if usecs != None:
            log.debug("Set B-Width %d us." % (usecs))
            self._bwidth = usecs
        if self._connected:
            # clks = int(self._bwidth * NMR_PG_CLK / 1E6 + 0.5)
            # print("B-width: %f us = %d clks, real time = %.8f" % (self._bwidth, clks, clks / NMR_PG_CLK))
            self._send_cmd(Command.SET_BWIDTH, self._bwidth)

    @property
    def abdelay(self): return self._abdelay
    def set_abdelay(self, usecs = None):
        if usecs != None:
            log.debug("Set AB-Delay %d us." % (usecs))
            self._abdelay = usecs
        if self._connected:
            # clks = int(self._abdelay * NMR_PG_CLK / 1E6 + 0.5)
            self._send_cmd(Command.SET_ABDELAY, self._abdelay)

    @property
    def bbdelay(self): return self._bbdelay
    def set_bbdelay(self, usecs = None):
        if usecs != None:
            log.debug("Set BB-Delay %d us." % (usecs))
            self._bbdelay = usecs
        if self._connected:
            # clks = int(self._bbdelay * NMR_PG_CLK / 1E6 + 0.5)
            self._send_cmd(Command.SET_BBDELAY, self._bbdelay)

    @property
    def bcount(self): return self._bcount
    def set_bcount(self, cnt = None):
        if cnt != None:
            log.debug("Set B-Count %d." % (cnt))
            self._bcount = cnt
        if self._connected:
            self._send_cmd(Command.SET_BCOUNT, self._bcount)

    @property
    def rxsize(self): return self._rxsize
    def set_rxsize(self, samples = None):
        if samples != None:
            self._rxsize = samples
            log.debug("Set rxsize %d" % (self._rxsize))
        if self._connected:
            self._send_cmd(Command.SET_RX_SIZE, self._rxsize)

    @property
    def rxdelay(self): return self._rxdelay
    def set_rxdelay(self, usecs = None):
        if usecs is not None:
            self._rxdelay = usecs
            log.debug("Set Rx-Delay %d us." % (usecs))
        if self._connected:
            self._send_cmd(Command.SET_RX_DELAY, self._rxdelay)

    @property
    def amp(self): return self._amp
    def set_amp(self, on = False):
        self._amp = on 
        log.debug("Set Amplifier %d." % (on))
        if self._connected:
            self._send_cmd(Command.SET_AMP, self._amp)


class CommandReply(object):
    def __init__(self):
        self.id = -1
        self.resultcode = 98
        self.data_len = 0
        self.data = None

    def __repr__(self):
        return "CommandReply(id = %d, resultcode = %d, data_len = %d)" % (self.id, self.resultcode, self.data_len)

class NMRError(Exception): pass

class NMRNoDataError(NMRError): pass
class NMRCmdError(NMRError): pass
class NMRConnectionError(NMRError): pass
class NMRConnectError(NMRError): pass
class NMRTimeoutError(NMRError): pass

if __name__ == "__main__":
    main()
