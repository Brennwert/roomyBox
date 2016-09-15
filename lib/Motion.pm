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

