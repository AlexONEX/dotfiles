#!/usr/bin/env python

import sys
import dbus
import argparse

parser = argparse.ArgumentParser()
parser.add_argument(
    '-t',
    '--trunclen',
    type=int,
    metavar='trunclen'
)
parser.add_argument(
    '-f',
    '--format',
    type=str,
    metavar='custom format',
    dest='custom_format'
)
parser.add_argument(
    '-p',
    '--playpause',
    type=str,
    metavar='play-pause indicator',
    dest='play_pause'
)
parser.add_argument(
    '--font',
    type=str,
    metavar='the index of the font to use for the main label',
    dest='font'
)
parser.add_argument(
    '--playpause-font',
    type=str,
    metavar='the index of the font to use to display the playpause indicator',
    dest='play_pause_font'
)
parser.add_argument(
    '-q',
    '--quiet',
    action='store_true',
    help="if set, don't show any output when the current song is paused",
    dest='quiet',
)

args = parser.parse_args()


def fix_string(string):
    # corrects encoding for the python version used
    if sys.version_info.major == 3:
        return string
    else:
        return string.encode('utf-8')

def truncate(name, trunclen):
    if len(name) > trunclen:
        name = name[:trunclen]
        name += '...'
        if ('(' in name) and (')' not in name):
            name += ')'
    return name


# Default parameters
output = fix_string(u'{play_pause} {artist}: {song}')
trunclen = 35
play_pause = fix_string(u'\u25B6,\u23F8') # first character is play, second is paused

label_with_font = '%{{T{font}}}{label}%{{T-}}'
font = args.font
play_pause_font = args.play_pause_font

quiet = args.quiet

# parameters can be overwritten by args
if args.trunclen is not None:
    trunclen = args.trunclen
if args.custom_format is not None:
    output = args.custom_format
if args.play_pause is not None:
    play_pause = args.play_pause

try:
    bus = dbus.SessionBus()
    sayonara = bus.get_object('org.mpris.MediaPlayer2.sayonara',
                              '/org/mpris/MediaPlayer2')
    metadata = sayonara.Get('org.mpris.MediaPlayer2.Player', 'Metadata',
                            dbus_interface='org.freedesktop.DBus.Properties')
    status = sayonara.Get('org.mpris.MediaPlayer2.Player',
                          'PlaybackStatus')

    if status == 'Playing':
        play_pause = play_pause[0]
    else if status == 'Paused':
        play_pause = play_pause[1]
    else:
        play_pause = str()

    if play_pause_font is not None:
        play_pause = label_with_font.format(font=play_pause_font, label=play_pause)

    artist = fix_string(metadata['xesam:artist'][0])
    song = fix_string(metadata['xesam:title'])
     if (quiet and status == 'Paused') or (not artist and not song and not album):
        print(' Paused')
    else:
        if font:
            artist = label_with_font.format(font=font, label=artist)
            song = label_with_font.format(font=font, label=song)
            album = label_with_font.format(font=font, label=album)

        # Add 4 to trunclen to account for status symbol, spaces, and other padding characters
        print(truncate(output.format(artist=artist,
                                     song=song,
                                     play_pause=play_pause,
                                     album=album), trunclen + 4))

except Exception as e:
    if isinstance(e, dbus.exceptions.DBusException):
        print(' Not Running')
    else:
        print(' Error')

