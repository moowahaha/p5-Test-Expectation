use strict;
use lib qw(./t/lib ./lib);
use Monkey;
use Test::Expectation;
use Data::Dumper;
use Test::More;

it_is_a 'Monkey';

it_should "eat a banana", sub {
    Monkey->expects('banana');
    Monkey->eat();
};

it_should "look at a lady monkey", sub {
    Monkey->expects('focus')->with('lady monkey');
    Monkey->look();
};

it_should "defend itself", sub {
    Monkey->expects('swing')->to_return('punches');

    is_deeply(
        Monkey->fight,
        'punches',
        'monkey fights real good'
    );
};

it_should "scratch itself", sub {
    Monkey->expects('itch')->with('bite')->to_return('swelling');

    Monkey->scratch();
};

it_should "explode when it smokes dynamite", sub {
    Monkey->expects('cigar')->to_raise('kaboom!');

    is_deeply(
        Monkey->smoke(),
        'oops!',
        'monkey smoked dynamite'
    );
};

