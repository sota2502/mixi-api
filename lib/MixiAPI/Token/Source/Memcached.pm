package MixiAPI::Token::Source::Memcached;
use strict;
use warnings;

use base qw/
    MixiAPI::Token::Source::Base
/;

use MixiAPI::Constants;
use Cache::Memcached::Fast;
use Carp;
use JSON::Syck;


sub _memcached {
    my $class = shift;
    my $memcached = Cache::Memcached::Fast->new({
        servers   => MixiAPI::Constants::MEMCACHED_HOSTS,
        namespace => MixiAPI::Constants::MEMCACHED_NAMESPACE,
    });
}


sub _set {
    my ($class, %args) = @_;
    map {
        defined $args{$_} or Carp::croak("required $_")
    } qw/code access_token refresh_token expire/;

    # serialize for Tokyo Tyrant
    my $value = JSON::Syck::Dump({
        access_token  => $args{access_token},
        refresh_token => $args{refresh_token},
        expire        => $args{expire},
    });

    # default expire: 30days
    return $class->_memcached->set( $args{code}, $value );
}


sub _get {
    my ($class, %args) = @_;
    map {
        defined $args{$_} or Carp::croak("required $_")
    } qw/code/;

    my $json = $class->_memcached->get( $args{code} );
    return unless ( $json );

    return JSON::Syck::Load( $json );
}


sub insert {
    my ($class, %args) = @_;

    my $ret;
    eval {
        $ret = $class->_set( %args );
    };
    if( $@ ) {
        Carp::croak( 'fail insert:'.  $@ );
    }

    return $ret;
}


sub update {
    my ($class, %args) = @_;

    my $ret;
    eval {
        $ret = $class->_set( %args );
    };
    if( $@ ) {
        Carp::croak( 'fail insert:'.  $@ );
    }

    return $ret;
}


sub select {
    my ($class, %args) = @_;

    my $row;
    eval {
        $row = $class->_get( %args );
    };
    if( $@ ) {
        Carp::croak( 'fail select:'.  $@ );
    }

    return unless $row;

    $row->{code} = $args{code};

    return $row;
}


1;
