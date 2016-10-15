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


package roomyBox;

use Dancer2;
use Music;

# Initialization:

system('mocp -S > /dev/null 2>&1');

my $music = Music->new(
		fileHome => config->{musicHome},
		audioDevice => config->{audioDevice},
	);

if (config->{musicAutostart}) {
	sleep 1; # Let MOC-server start...
	$music->setPath( config->{musicHome} . '/' . config->{musicAutostart} );
	$music->play();
}


# Routes:

get '/' => sub {
    template 'index';
};


get '/music/*' => sub {

	my ($area) = splat;

	$music->{arg} = param('arg');
	$music->setPath( param('path') );

    return $music->$area;

};

true;
