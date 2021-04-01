from array import array
import pyaudio
import subprocess
import sys

START_THRESHOLD = 150
STOP_THRESHOLD = 50
CHUNK_SIZE = 2048
FORMAT = pyaudio.paInt16
RATE = 48000
# TODO pass these as args
hifipi_ip="10.30.80.100"
ls_stream="Turntable_stream"

def is_silent(snd_data, threshold):
    """
    Returns 'True' if below the 'silent' threshold"
    :param snd_data:
    :return: True|False
    """
    return max(snd_data) < threshold


def listen():
    """
    listen to default input device and perform an action if sound starts or stops
    """
    p = pyaudio.PyAudio()
    snd_started = False
    while 1:
        # using default input -- needs to be dsnoop configured in alsa
        stream = p.open(format=FORMAT, channels=2, rate=RATE, input=True, output=False, frames_per_buffer=CHUNK_SIZE)
        # little endian, signed short
        snd_data = array('h', stream.read(CHUNK_SIZE))
        if sys.byteorder == 'big':
            snd_data.byteswap()

        #print(f"Current Noise data: {max(snd_data)}")
        #time.sleep(0.5)

        if (not snd_started) and (not is_silent(snd_data, START_THRESHOLD)):
            sys.stdout.write(f"start stream. Volume: {max(snd_data)}\n")
            start = subprocess.run(["mpc", f"--host={hifipi_ip}","play"], capture_output=True, text=True)
            if start.stdout:
                received_stream = start.stdout.splitlines()[0]
                if received_stream != ls_stream:
                    sys.stderr.write(f"Unexpected stream response. Received:{received_stream}, expected:{ls_stream}. Command:{start.args} mpc clear and add playlist again\n")
                else:
                    sys.stdout.write(f"mpc output:{start.stdout}")
                    snd_started = True
            elif start.stderr:
                sys.stderr.write(f"mpc play error. Full command result:{start}. Ideally mpc clear and add here")
                # TODO: do this
                # mpc --host=${hifipi_ip} clear
                # mpc --host=${hifipi_ip} add http://"${my_ip}":${def_icecast_port}/${ls_name}.ogg
        elif snd_started and is_silent(snd_data, STOP_THRESHOLD):
            sys.stdout.write(f"stop stream. Volume: {max(snd_data)}\n")
            stop = subprocess.run(["mpc", f"--host={hifipi_ip}","stop"], capture_output=True, text=True)
            if stop.stdout: sys.stdout.write(f"mpc output:{stop.stdout}")
            if stop.stderr: sys.stderr.write(f"mpc output:{stop.stderr}")
            snd_started = False

        stream.stop_stream()
        stream.close()


if __name__ == '__main__':
    listen()