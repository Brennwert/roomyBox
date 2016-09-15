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


package Music;

use Moose;
use JSON;
use Dancer2 qw(:script);
use Encode;

has 'fileHome' => (is => 'rw', isa => 'Str');
has 'filePath' => (is => 'rw', isa => 'Str');
has 'audioDevice' => (is => 'rw', isa => 'Str');
has 'arg' => (is => 'rw', isa => 'Str');


sub setPath {
	my $self = shift;
	my $path = shift;

	$self->filePath($self->{fileHome});

	if ( $path && $path ne 'undefined' && $path =~ /^$self->{fileHome}/ && $path !~ /\/\.\./ && $path !~ /;/ ) {
		$self->filePath( encode("UTF-8", $path) );	
	} 

	return $self->filePath();
}


sub trackList {
	my $self = shift;

	my $path = $self->filePath();

	my @list = <"$path/*">;
	my @json = ();

	foreach my $entry (@list) {

		$entry = decode("UTF-8", $entry);
		
		
		my ($name) = $entry =~ /.*\/(.*)$/;
		my $type = -f $entry ? 'f' : 'd';

		# Strip file-ending for nicer look:
		$name =~ s/\.\w{3}$// if $type eq 'f';

		push @json, {
			path => $entry,
			name => $name,
			type => $type,
		}
	}


	return to_json { 
		list => [ @json ],
		directory => { 
				path => $path,
				isRoot => $path eq $self->{fileHome} ? 1 : 0,
			}, 
	};
}


sub currentTrack {
	# Transforms mocp-info to JSON-hash.

	my @info = `mocp -i`;

	my %info;

	foreach (@info) {
		chomp();
		$_ = decode("UTF-8", $_);

		my ($desc, $cont) = split(/:\s/, $_);
		$info{$desc} = $cont;
	}

	return to_json { %info };
}


sub play {
	my $self = shift;

	my $path = $self->filePath();

	if ($path ne $self->{fileHome}) {

		# Play a new file:
		if ( $path =~ /\.m3u$/) {

			# Single playlist-file. Add and play:
			system("mocp -c -a '$path' -p");

		} else {
			
			# Play file and all following in directory.
			system("mocp -c");
			my ($base,$playFile) = $path =~ (/^(.*)\/(.*)/);
			my @fileList = <"$base/*">;

			my $add = 0;
			foreach my $file (@fileList) {
				$add = 1 if $file eq $path;
				system("mocp -a '$file'") if $add;
			}
			system("mocp -p");

		}

	} else {

		# Just unpause:
		system('mocp -U');
	}

	return 1;
}


sub pause {
	system('mocp -P');
	return 1;
}

sub prev {
	system('mocp -r');
	return 1;
}

sub next {
	system('mocp -f');
	return 1;
}

sub repeat {
	system('mocp -t repeat');
	return 1;
}

sub volUp {
	my $self = shift;
	return $self->setVolume( $self->getVolume() + 5 );
}


sub volDown {
	my $self = shift;
	return $self->setVolume( $self->getVolume() - 5 );
}

sub setVolume {
	my $self = shift;
	system('amixer set ' . $self->{audioDevice} . ' ' . $self->{arg} . '%');
	return to_json { volume => $self->{arg} };
}


sub getVolume {
	my $self = shift;
	my $vol = `amixer get $self->{audioDevice} | tail -n 1`;
	$vol =~ s/.*\[(\d+)\%\].*/$1/;
	chomp($vol);
	return to_json { volume => $vol };
}

__PACKAGE__->meta->make_immutable;

1;


