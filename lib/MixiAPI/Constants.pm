package MixiAPI::Constants;
use strict;
use warnings;

sub TOKEN_SOURCE {
    return 'Input you want to use token storage';
}

sub DB_DSN {
    return 'Input DSN if you use MySQL, SQLite';
}

sub DB_USER {
    return 'Input DB USER NAME';
}

sub DB_PASSWORD {
    return 'Input DB PASSWORD';
}

sub CONSUMER_KEY {
    return 'Input your mixi api consumer key';
}

sub CONSUMER_SECRET {
    return 'Input your mixi api consumer secret';
}

sub REDIRECT_URL {
    return 'Input redirect url you make setting on mixi developer center';
}

1;

__END__
=encoding utf-8

=pod

=head1 NAME

MixiAPI::Constants

=head1 DESCRIPTION

The settings which required when your application use mixi graph api
