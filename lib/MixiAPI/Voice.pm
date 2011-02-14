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

__END__

=encoding utf-8

=pod

=head1 NAME

MixiAPI::Voice - Module for getting mixi Voice user_timeline and friends_timeline by access token

=head1 SYNOPSIS

  use MixiAPI::Token;
  use MixiAPI::Voice;

  my $token = MixiAPI->lookup('code');
  my $user_timeline = MixiAPI::Voice->user_timeline( $code );

  foreach my $entry (@$user_timeline) {
    print $entry->{user}->{screen_name};
    print $entry->{user}->{profile_image_url};
    print $entry->{user}->{url};
    print $_->{text};
    print $_->{created_at};
  }

=head1 DESCRIPTION

アクセストークンにより指定したユーザー、もしくはユーザーの友人のつぶやき一覧を取得します。

=head1 CLASS METHOD

=head2 user_timeline( $token, $user )

指定したユーザーのつぶやき一覧(Array ref)を返します。

$token: MixiAPI::Token のインスタンス。

$user: $tokenにより認証されたユーザ自身、もしくはフレンド。

=head2 friends_timeline( $token )

recent_voice.pl で取得される友人のつぶやき一覧を返します。

=head1 SEE ALSO

=over 4

=item MixiAPI::Token

アクセストークンを扱うためのモジュールです

=item mixi Developer Center

http://developer.mixi.co.jp/connect/mixi_graph_api

=back

=head1 AUTHOR

Souta.Nakamori

=cut
