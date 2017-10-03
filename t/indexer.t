#!perl

use strict;
use warnings;

use Test::More;
use Capture::Tiny qw(capture_stderr);
use File::Temp qw(tempdir);

BEGIN {
    eval {require Search::Indexer};
    plan skip_all => 'Search::Indexer does not seem to be installed'
      if $@;
}

plan tests => 3;

use_ok( 'Pod::POM::Web::Indexer' );

subtest "indexing" => sub {
    plan tests => 2;

    my $ppwi = Pod::POM::Web::Indexer->new();

    $ppwi->{index_dir} = tempdir(CLEANUP => 1);
    my $output = capture_stderr {
        $ppwi->index();
    };
    like($output, qr/INDEXING/, "Creating index creates individual indices");

    $output = capture_stderr {
        $ppwi->index();
    };
    unlike($output, qr/INDEXING/, "Rerunning index avoids recreation");
};

subtest "uri escape" => sub {
    plan tests => 3;
    is(uri_escape(), undef, "An escaped, undefined URI stays undefined");

    my $plain_uri = "http://example.com";
    is(uri_escape($plain_uri), $plain_uri, "Plain URI remains unchanged");

    my $unescaped_uri = "http://example.com/^;/?:\@,Az0-_.!~*'()";
    my $escaped_uri = "http://example.com/%5E;/?:\@,Az0-_.!~*'()";
    is(uri_escape($unescaped_uri), $escaped_uri, "Non-standard characters escaped in URI");
};

sub uri_escape {
    my $uri = shift;
    return Pod::POM::Web::Indexer::uri_escape($uri);
}

# TODO ... more than just a compile test
