package MixiAPI::Base;
use strict;
use warnings;


use base qw/
    Class::Data::Inheritable
    Class::Accessor::Fast
/;

use Carp;
use LWP::UserAgent;
use URI;
use URI::QueryParam;


__PACKAGE__->mk_classdata( _user_agent => undef );


sub user_agent {
    my $class = shift;
    return $class->_user_agent if ( $class->_user_agent );

    my $ua = LWP::UserAgent->new();
    $class->_user_agent( $ua );
    return $ua;
}


sub create_url {
    my ($class, $end_point, $params) = @_;
    unless ( $end_point ) {
        Carp::croak('required end_point');
    }

    $params ||= {};
    my $uri = URI->new($end_point);
    $uri->query_form_hash( %$params );

    return $uri->as_string;
}


sub decode_json {
    my ($clas, $data) = @_;
    unless ( $data ) {
        Carp::croak('required data');
    }

    require JSON;
    return JSON::decode_json($data);
}


1;
