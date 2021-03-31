from array import array
import pyaudio
import subprocess
import sys

THRESHOLD = 350
CHUNK_SIZE = 2048
FORMAT = pyaudio.paInt16
RATE = 48000
hifipi_ip="10.30.80.100"


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
    snd_started = False
    r = array('h')
    while 1:
        # using default input -- needs to be dsnoop configured in alsa
        stream = p.open(format=FORMAT, channels=2, rate=RATE, input=True, output=False, frames_per_buffer=CHUNK_SIZE)
        # little endian, signed short
        snd_data = array('h', stream.read(CHUNK_SIZE))
        if sys.byteorder == 'big':
            snd_data.byteswap()
        r.extend(snd_data)

        if is_silent(snd_data):
            if snd_started:
                sys.stdout.write(f"stop stream. Volume: {max(snd_data)}\n")
                subprocess.run(["mpc", f"--host={hifipi_ip}","stop"])
                snd_started = False
        elif not snd_started:
            sys.stdout.write(f"start stream. Volume: {max(snd_data)}\n")
            # TODO: check mpc --host=10.30.80.100 playlist should return My Turntable, if not --clear and add again
            # TODO: create function to check if playlist loaded and detect other issues?
            subprocess.run(["mpc", f"--host={hifipi_ip}","play"])
            snd_started = True

        stream.stop_stream()
        stream.close()


if __name__ == '__main__':
    listen()