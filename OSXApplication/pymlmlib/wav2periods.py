import mlmlib
import wave
import struct
import sys

def int24_to_int(input_data):
    bytelen = len(input_data)
    frames = bytelen/3
    triads = struct.Struct('3s' * frames)
    int4byte = struct.Struct('<i')
    result = [int4byte.unpack('\0' + i)[0] >> 8 for i in triads.unpack(input_data)]
    return result
    
def main():
    w = wave.open(sys.argv[1])
    m = mlmlib.mlm()
    width = w.getsampwidth()
    nch = w.getnchannels()
    for i in range(0, w.getnframes()):
        rawData = w.readframes(1)
        if width == 2:
            data = struct.unpack("<h", rawData)
            m.feedint(data, width, nch)
        elif width == 3:
            # Grr, this is difficult
            data = int24_to_int(rawData)
            m.feedint(data, 4, nch)
        elif width == 4:
            data = struct.unpack("<i", rawData)
            m.feedint(data, width, nch)
        else:
            print >> sys.stderr, "Unknown width", width
            sys.exit(1)
        if m.ready():
            while True:
                c = m.consume()
                if c >= 0:
                    print c
                else:
                    break

    print >> sys.stderr, 'amplitude', m.amplitude()
    print >> sys.stderr,'min', m.min()
    print >> sys.stderr,'max', m.max()
    print >> sys.stderr,'average', m.average()
    
if __name__ == '__main__':
    main()
    
