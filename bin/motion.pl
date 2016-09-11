#!/usr/bin/perl

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
            $voice->say("Hallihallo!");
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

    	# Turn off screen (but wait a minute after boot):
        if (time() - $startTime > 60) {
            system('echo 1 > /sys/class/backlight/rpi_backlight/bl_power');
        }

    	# Pause music if it's playing:
    	my $track = from_json $music->currentTrack();
    	if ($track->{State} eq 'PLAY') {
    		print "Pausing music\n";
    		$music->pause();
    		$motion->pausedMusic(1);
    	}
    }

    Device::BCM2835::delay(500);
}
