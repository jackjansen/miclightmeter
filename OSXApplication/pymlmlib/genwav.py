import mlmlib
import wave
import sys

def main():
    if (len(sys.argv)-2) % 3 != 0:
        print >> sys.stderr, "Usage: %s wavfile min max sweepfreq [min max sweepfreq ...]"
        sys.exit(1)
    w = wave.open(sys.argv[1], 'w')
    w.setnchannels(2)
    w.setsampwidth(2)
    w.setframerate(8000)
    for i in range(2, len(sys.argv), 3):
        min = float(sys.argv[i])
        max = float(sys.argv[i+1])
        sweep = float(sys.argv[i+2])
        data = mlmlib.generate(min, max, sweep, 0)
        w.writeframes(data)
    w.close()
    
if __name__ == '__main__':
    main()
    
