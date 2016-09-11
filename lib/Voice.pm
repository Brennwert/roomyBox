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

