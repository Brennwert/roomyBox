package roomyBox;

use Dancer2;
use Music;

my $music = Music->new(
		fileHome => config->{musicHome},
		audioDevice => config->{audioDevice},
	);

system('mocp -S > /dev/null 2>&1');


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
