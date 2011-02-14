package MixiAPI::Voice;
use strict;
use warnings;

use constant {
    _END_POINT => 'http://api.mixi-platform.com/2/voice/statuses',
};

use base qw/
    MixiAPI::Base
/;

use Carp;


sub user_timeline {
    my ($class, $token, $user) = @_;
    unless ( $token && $token->isa('MixiAPI::Token') ) {
        Carp::croak('invalid token');
    }

    $user ||= '@me';

    my $url = $class->create_url( _END_POINT . "/$user/user_timeline", {
        oauth_token => $token->access_token,
    });
    my $res = $class->user_agent->get($url);
    unless ( $res && $res->is_success ) {
        Carp::croak('fail get http response');
    }

    return $class->decode_json( $res->content );
}


sub friends_timeline {
    my ($class, $token) = @_;
    unless ( $token && $token->isa('MixiAPI::Token') ) {
        Carp::croak('invalid token');
    }

    my $url = $class->create_url( _END_POINT . '/friends_timeline/', {
        oauth_token => $token->access_token,
    });
    my $res = $class->user_agent->get($url);
    unless ( $res && $res->is_success ) {
        Carp::croak('fail get http response');
    }

    return $class->decode_json( $res->content );
}


1;
