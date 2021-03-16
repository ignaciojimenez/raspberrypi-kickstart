from sys import byteorder
from array import array
import pyaudio

THRESHOLD = 250
CHUNK_SIZE = 1024
FORMAT = pyaudio.paInt16
RATE = 44100


def is_silent(snd_data):
    """
    Returns 'True' if below the 'silent' threshold"
    :param snd_data:
    :return: True|False
    """
    return max(snd_data) < THRESHOLD


def listen():
    """
    Record a word or words from the microphone and
    return the data as an array of signed shorts.
    """
    p = pyaudio.PyAudio()
    stream = p.open(format=FORMAT, channels=1, rate=RATE,
                    input=True, output=True,
                    frames_per_buffer=CHUNK_SIZE)
    snd_started = False
    r = array('h')
    while 1:
        # little endian, signed short
        snd_data = array('h', stream.read(CHUNK_SIZE))
        if byteorder == 'big':
            snd_data.byteswap()
        r.extend(snd_data)

        if is_silent(snd_data):
            if snd_started:
                # print(f"stop stream: {max(snd_data)}")
                snd_started = False
        elif not snd_started:
            # print(f"start stream: {max(snd_data)}")
            snd_started = True


if __name__ == '__main__':
    listen()
