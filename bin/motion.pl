#!/usr/bin/perl

# Copyright (C) 2016 Markus Wolf <roomybox@wolf.place>
#
# This file is part of roomyBox.
#
# roomyBox is free software: you can redistribute it and/or  modify
# it under the terms of the GNU Affero General Public License, version 3,
# as published by the Free Software Foundation.
#
# roomyBox is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with roomyBox.  If not, see <http://www.gnu.org/licenses/>.


use strict;
use warnings;
use Device::BCM2835;
use YAML::XS 'LoadFile';
use JSON;

my $cwd;
BEGIN { ($cwd) = $0 =~ /^(.*)\/bin\/.*$/ }

use lib "$cwd/lib";
use Motion;
use Voice;
use Music;

my $config = LoadFile("$cwd/config.yml");
my $lang = LoadFile("$cwd/language/$config->{voiceLanguage}.yml");

mkdir $config->{voiceCache} if ! -d $config->{voiceCache};

my $voice = Voice->new(
		language => $config->{voiceLanguage}, 
		apiKey => $config->{voiceApiKey}, 
        quality => $config->{voiceQuality},
		cacheDir => $config->{voiceCache},
	);

my $motion = Motion->new(
		motionThreshold => $config->{motionThreshold},
	);

my $music = Music->new(
		fileHome => $config->{musicHome},
		filePath => $config->{musicHome},
		audioDevice => $config->{audioDevice},
	);

Device::BCM2835::init() || die "Could not init BCM-library";
Device::BCM2835::gpio_fsel(&Device::BCM2835::RPI_GPIO_P1_18, &Device::BCM2835::BCM2835_GPIO_FSEL_INPT);

my $startTime = time();

while (1)
{
    my $pir = Device::BCM2835::gpio_lev(&Device::BCM2835::RPI_GPIO_P1_18);

    print "PIR: $pir\n";

    if ($pir == 1) {

        # If returned from long absence: Say good morning / evening / hello:
        if ( time() - $motion->{lastMotion} > $config->{absenceThreshold} ) {
            print "Greeting\n";
	    $voice->say( $lang->{greetings}[rand @{ $lang->{greetings} }] );
        }

        # Read RSS

    	$motion->lastMotion(time());
    }


    if ($motion->someoneThere()) {
    	print "Someone's in the room.\n";

    	# Turn on screen:
        system('echo 0 > /sys/class/backlight/rpi_backlight/bl_power');

    	# Resume music if I paused it
        if ($motion->{pausedMusic}) {
            print "Resuming music\n";
            $music->play();
            $motion->pausedMusic(0);
        }


    } else {
    	print "Room empty.\n";

    	# Wait a minute after boot until turning anything off:
        if (time() - $startTime > 60) {
	    # Turn off screen:
            system('echo 1 > /sys/class/backlight/rpi_backlight/bl_power');

   	    # Pause music if it's playing:
	    my $track = from_json $music->currentTrack();
	    if ($track->{State} eq 'PLAY') {
		print "Pausing music\n";
		$music->pause();
		$motion->pausedMusic(1);
	    }
        }
    }

    Device::BCM2835::delay(500);
}
