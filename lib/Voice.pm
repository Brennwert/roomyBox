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


package Voice;

use Moose;

has 'language' => (is => 'rw', isa => 'Str');
has 'apiKey' => (is => 'rw', isa => 'Str');
has 'cacheDir' => (is => 'rw', isa => 'Str');
has 'quality' => (is => 'rw', isa => 'Str');

our $voiceRSS = 'http://api.voicerss.org/';

sub say {
	my $self = shift;
	my $text = shift;

	my $soundfile = "$self->{cacheDir}/$self->{language}_$text.mp3";

	if (! -f $soundfile) {
		print "Fetching text2speech: $soundfile\n";
		system("wget -q -O '$soundfile' '$voiceRSS?key=$self->{apiKey}&hl=$self->{language}&f=$self->{quality}&src=$text'");
	}
	system("mpg123 -q '$soundfile'");
}

__PACKAGE__->meta->make_immutable;

1;

