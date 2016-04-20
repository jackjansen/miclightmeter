import ctypes
import os

_mlmlib = None
MLMLIB=os.environ.get("MLMLIB", "libmlmlib.dylib")

def init_mlmlib():
    global _mlmlib
    if _mlmlib is None:
        _mlmlib = ctypes.cdll.LoadLibrary(MLMLIB)
        _mlmlib.mlm_new.argtypes = []
        _mlmlib.mlm_new.restype = ctypes.c_void_p
        _mlmlib.mlm_destroy.argtypes = [ctypes.c_void_p]
        _mlmlib.mlm_destroy.restype = None
        _mlmlib.mlm_reset.argtypes = [ctypes.c_void_p]
        _mlmlib.mlm_reset.restype = None
        _mlmlib.mlm_feedfloat.argtypes = [ctypes.c_void_p]
        _mlmlib.mlm_feedfloat.restype = None
        _mlmlib.mlm_feedint.argtypes = [ctypes.c_void_p]
        _mlmlib.mlm_feedint.restype = None
        _mlmlib.mlm_feedmodulation.argtypes = [ctypes.c_void_p]
        _mlmlib.mlm_feedmodulation.restype = None
        _mlmlib.mlm_ready.argtypes = [ctypes.c_void_p]
        _mlmlib.mlm_ready.restype = ctypes.c_int
        _mlmlib.mlm_amplitude.argtypes = [ctypes.c_void_p]
        _mlmlib.mlm_amplitude.restype = ctypes.c_double
        _mlmlib.mlm_min.argtypes = [ctypes.c_void_p]
        _mlmlib.mlm_min.restype = ctypes.c_double
        _mlmlib.mlm_max.argtypes = [ctypes.c_void_p]
        _mlmlib.mlm_max.restype = ctypes.c_double
        _mlmlib.mlm_average.argtypes = [ctypes.c_void_p]
        _mlmlib.mlm_average.restype = ctypes.c_double
        _mlmlib.mlm_current.argtypes = [ctypes.c_void_p]
        _mlmlib.mlm_current.restype = ctypes.c_double
        _mlmlib.mlm_consume.argtypes = [ctypes.c_void_p]
        _mlmlib.mlm_consume.restype = ctypes.c_double
        _mlmlib.mlm_generate.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_float, ctypes.c_float, ctypes.c_float, ctypes.c_int]
        _mlmlib.mlm_generate.restype = ctypes.c_int

class Error(RuntimeError):
    pass


class mlm:
    def __init__(self):
        init_mlmlib()
        self._mlm = _mlmlib.mlm_new()
        
    def __del__(self):
        if self._mlm:
            _mlmlib.mlm_destroy(self._mlm)
        self._mlm = None
        
    def reset(self):
        _mlmlib.mlm_reset(self._mlm)
        
    def feedint(self, data, bytespersample, channels):
        if not data: return
        if bytespersample == 1:
            dataType = ctypes.c_int8*len(data)
        elif bytespersample == 2:
            dataType = ctypes.c_int16*len(data)
        elif bytespersample == 4:
            dataType = ctypes.c_int32*len(data)
        else:
            raise Error, "Unsupported bytespersample %d" % bytespersample
        _mlmlib.mlm_feedint(self._mlm, dataType(*tuple(data)), ctypes.c_int(bytespersample*len(data)), ctypes.c_int(bytespersample), ctypes.c_int(channels))
            
    def feedfloat(self, data, channels):
        if not data: return
        dataType = ctypes.c_float*len(data)
        _mlmlib.mlm_feedfloat(self._mlm, dataType(*tuple(data)), ctypes.c_int(len(data)), ctypes.c_int(channels))
            
    def feedModulation(self, duration):
        _mlmlib.mlm_feedmodulation(self._mlm, ctypes.c_float(duration))
        
    def ready(self): return _mlmlib.mlm_ready(self._mlm)
    def amplitude(self): return _mlmlib.mlm_amplitude(self._mlm)
    def min(self): return _mlmlib.mlm_min(self._mlm)
    def max(self): return _mlmlib.mlm_max(self._mlm)
    def average(self): return _mlmlib.mlm_average(self._mlm)
    def current(self): return _mlmlib.mlm_current(self._mlm)
    def consume(self): return _mlmlib.mlm_consume(self._mlm)
    
def generate(minLevel, maxLevel, sweepFreq, wantHeader):
    init_mlmlib()
    bufSize = _mlmlib.mlm_generate(None, 0, minLevel, maxLevel, sweepFreq, wantHeader)
    print 'bufSize=', bufSize
    buffer = ctypes.create_string_buffer(bufSize)
    bs2 = _mlmlib.mlm_generate(buffer, bufSize, minLevel, maxLevel, sweepFreq, wantHeader)
    assert bs2 == bufSize
    return buffer.raw
        
def _test():
    m = mlm()
    print 'mlm address is %x' % m._mlm
    m.feedint([0, 255, 0, -255, 0, 255, 0, -255,0, 255, 0, -255,0, 255, 0, -255,0], 2, 1)
    m.feedint([0, 16777216, 0, -16777216, 0, 16777216, 0, -16777216,0, 16777216, 0, -16777216,0, 16777216, 0, -16777216,0], 4, 1)
    m.feedfloat([0.0, 0.004, 0.0, -0.004,0.0, 0.004, 0.0, -0.004, 0.0, 0.004, 0.0, -0.004, 0.0, 0.004, 0.0, -0.004,  0.0], 1)
    print 'ready', m.ready()
    print 'amplitude', m.amplitude()
    print 'min', m.min()
    print 'max', m.max()
    print 'average', m.average()
    print 'consume',
    while True:
        c = m.consume()
        print c,
        if c < 0: break
    print
    del m
    data2 = generate(0.5, 0.5, 0, 1)
    print 'generate (steady half light, header) returned %d bytes' % (len(data2))
    data4 = generate(0, 1, 4, 0)
    print 'generate (sweep of 4 Hz, no header) returned %d bytes' % (len(data4))
    print 'all done'
    
if __name__ == '__main__':
    _test()
    
    
