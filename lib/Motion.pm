package Motion;

use Moose;

has 'lastMotion' => (is => 'rw', isa => 'Int', default => 0);
has 'motionThreshold' => (is => 'rw', isa => 'Int');
has 'pausedMusic' => (is => 'rw', isa => 'Bool');


sub someoneThere {
	my $self = shift;
	if (time() - $self->{lastMotion} > $self->{motionThreshold}) {
		return 0;
	}

	return 1;
}

__PACKAGE__->meta->make_immutable;

1;

