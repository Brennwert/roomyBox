# roomyBox
This is an application-bundle and UI meant to be nice having around on a touchscreen-computer somewhere in your house. Turns the screen on when you enter the room and resumes your music that stopped when you left. Shows you clock, weather, musicplayer or any other widget you'd like to code.<br>
The frontend is built on ReactJS (were my first steps with it). The backend is a Perl Dancer2 server.
<br><br>
<img src="http://roomybox.wolf.place/images/screenshots/screenshot1.png" width="400">
<img src="http://roomybox.wolf.place/images/screenshots/screenshot2.png" width="400">
<br><br>
See <a href="http://roomybox.wolf.place">roomybox.wolf.place</a> for an example of a housing around it.
<hr>

## Installation

### Prerequisites
* MOC
* Dancer2
* Moose
* Perl Encode-lib
* Modern browser (preferably Chromium)
* Optional: BCM2835 Perl-lib for motion-detector
* Optional: mpg123 for voice-output

#### To get all this on Raspbian:

`sudo apt-get install moc libdancer2-perl libmoose-perl libencode-perl mpg123`

Chromium:
```
wget -qO - http://bintray.com/user/downloadSubjectPublicKey?username=bintray | sudo apt-key add -
echo "deb http://dl.bintray.com/kusti8/chromium-rpi jessie main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install chromium-browser
```

BCM2835-libs:
```
wget http://www.airspayce.com/mikem/bcm2835/bcm2835-1.50.tar.gz
tar -xvzf bcm2835-1.50.tar.gz 
cd bcm2835-1.50/
./configure 
make && make install
cpan -i Device::BCM2835
```

### Deployment
Get the source:<br>
`cd /opt/ && git clone https://github.com/Brennwert/roomyBox.git`

#### Backend
There are various ways to run the server, easiest is standalone:<br>
`sudo /opt/roomyBox/bin/app.pl`

If you want monit to ensure the backend starts on boot and recovers from (not yet happened) crashes, a monitrc-entry looks like this:
```
check host dancer with address 127.0.0.1
    start program = "/bin/bash -c '/opt/roomyBox/bin/app.pl &>/var/log/roomyBox.log &'"
    stop program  = "/bin/bash -c 'ps aux|egrep \'perl.*app.pl\'|grep -v grep|awk \'{print $2}\'|xargs kill -9'"
    if failed port 3000 protocol HTTP
      request /
      with timeout 3 seconds
      then restart
```
It's also handy to keep the MOC-server up:
```
check process mocp
        matching "mocp -S"
        if does not exist then exec "/bin/bash -c '/bin/rm -f /root/.moc/pid ; /usr/bin/mocp -S'"
```

For more elegant and multi-threading deployment-methods have a look at the Dancer2 docs:<br>
http://search.cpan.org/~cromedome/Dancer2-0.202000/lib/Dancer2/Manual/Deployment.pod

#### Browser-Kiosk
Add to `~/.config/lxsession/LXDE-pi/autostart`:<br>
`chromium-browser --kiosk --incognito http://localhost:3000 --display=:0 &`
<br><br>
To prevent screen-blanking set in `/etc/lightdm/lightdm.conf`:
```
xserver-command=X -s 0 dpms
```

### Configuration
You should at least set your Music-directory and API-key for weather-display in
<ul>
<li>config.yml (backend)</li>
<li>config.js (frontend)</li>
</ul>

### Trivia
The UI is optimized for my 7" touchscreen on 800*480 pixels. It's quiet responsive, but looks a bit lost on high resolutions.<br>
PIR sensor-pin is hardcoded to RPI_GPIO_P1_18 until someone finds a way making this a variable in motion.pl.
