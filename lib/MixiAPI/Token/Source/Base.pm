package MixiAPI::Token::Source::Base;
use strict;
use warnings;

sub insert {
    die 'require override';
}

sub update {
    die 'require override';
}

sub select {
    die 'require override';
}

1;

__END__
=encoding utf-8

=pod

=head1 NAME

  MixiAPI::Source::Base

=cut
