package MixiAPI::Token;
use strict;
use warnings;

use base qw/
    MixiAPI::Base
/;

use UNIVERSAL::require;
use MixiAPI::Constants;
use Carp;
use Date::Calc;

use constant {
    TOKEN_ENDPOINT => 'https://secure.mixi-platform.com/2/token',
    AUTH_ENDPOINT  => 'https://mixi.jp/connect_authorize.pl',
};

__PACKAGE__->mk_classdata( _user_agent => undef );
__PACKAGE__->mk_classdata( _source     => undef );

__PACKAGE__->mk_accessors(qw/
    code
    access_token
    refresh_token
    expire
/);


sub source {
    my $class = shift;
    return $class->_source if ( $class->_source );

    my $source = 'MixiAPI::Token::Source::' . MixiAPI::Constants->TOKEN_SOURCE;
    eval{
        $source->require;
    };
    if ( $@ ) {
        Carp::croak("fail load $source:" . $@);
    }

    $class->_source( $source );

    return $source;
}


sub lookup {
    my ($class, $code) = @_;
    Carp::croak( 'require code' ) unless ( $code );

    my $row = $class->source->select( code => $code );    
    return undef unless ( $row );

    my $self = $class->new({
        code          => $code,
        access_token  => $row->{access_token},
        refresh_token => $row->{refresh_token},
        expire        => $row->{expire},
    });
    if ( $self->is_expired ) {
        my $ret = $self->refresh;
        unless ( $ret ) {
            Carp::croak('fail refresh token');
        }
    }

    return $self;
}

sub create {
    my ($class, $code) = @_;
    croak 'require code' unless ($code);

    my $ua = $class->user_agent;
    my $token_res = $ua->post(TOKEN_ENDPOINT,{
        grant_type    => "authorization_code",
        client_id     => MixiAPI::Constants->CONSUMER_KEY,
        client_secret => MixiAPI::Constants->CONSUMER_SECRET,
        code          => $code,
        redirect_uri  => MixiAPI::Constants->REDIRECT_URL,
    });

    unless ( defined $token_res && $token_res->is_success ) {
        Carp::croak('fail token request');
    }

    my $href = $class->decode_json($token_res->content);

    my %params = (
        code          => $code,
        access_token  => $href->{access_token},
        refresh_token => $href->{refresh_token},
        expire        => _expire( $href->{expires_in} ),
    );

    my $ret;
    eval {
        $ret = $class->source->insert( %params );
    };
    if ( $@ ) {
        Carp::croak('fail db insert: ' . $@ );
    }
    unless ( $ret ) {
        Carp::croak('fail db insert: no effected record ' );
    }

    return $class->new( \%params );
}


sub refresh {
    my $self = shift;

    my $ua = $self->user_agent;
    my $token_res = $ua->post(TOKEN_ENDPOINT,{
        grant_type    => 'refresh_token',
        client_id     => MixiAPI::Constants->CONSUMER_KEY,
        client_secret => MixiAPI::Constants->CONSUMER_SECRET,
        refresh_token => $self->refresh_token,
    });

    unless ( defined $token_res && $token_res->is_success ) {
        Carp::croak('fail token request');
    }

    my $href = __PACKAGE__->decode_json($token_res->content);
    my $expire = _expire( $href->{expires_in} );

    my $ret;
    eval {
        $ret = $self->source->update(
            code          => $self->code,
            access_token  => $href->{access_token},
            refresh_token => $href->{refresh_token},
            expire        => $expire,
        );
    };
    if ( $@ ) {
        Carp::croak('fail db insert: ' . $@ );
    }
    unless ( $ret ) {
        Carp::croak('fail db insert: no effected record ' );
    }

    $self->access_token( $href->{access_token} );
    $self->refresh_token( $href->{refresh_token} );
    $self->expire( $expire );
    return 1;
}


sub is_expired {
    my $self = shift;

    my $now = sprintf "%04d%02d%02d%02d%02d%02d", Date::Calc::Today_and_Now;
    my $expire = _number_timestamp( $self->expire );

    return ( $now > $expire ) ? 1 : 0;
}


sub auth_url {
    my ($class, $scope) = @_;
    Carp::croak('require scope') unless ( $scope );

    return $class->create_url( AUTH_ENDPOINT, {
        client_id     => MixiAPI::Constants::CONSUMER_KEY,
        response_type => 'code',
        scope         => $scope,
        display       => 'pc',
    });
}

sub _expire {
    my $expire = shift;
    return sprintf (
        '%04d-%02d-%02d %02d:%02d:%02d',
        Date::Calc::Add_Delta_DHMS(
            Date::Calc::Today_and_Now(),
            0, 0, 0, $expire,
        ),
    );
}

sub _number_timestamp {
    my $timestamp = shift;
    $timestamp =~ s/\D//g;
    return $timestamp;
}



1;

__END__

=encoding utf-8

=pod

=head1 NAME

MixiAPI::Token  - Module for creating and updating easily mixi api token

=head1 SYNOPSIS

  use MixiAPI::Token;

  MixiAPI::Token->create('Authorization code');

  ####

  my $token = MixiAPI->lookup('code');
  my $user_timeline = MixiAPI::Voice->user_timeline( $code );

=head1 DESCRIPTION

mixi Graph API を扱う際の認証tokenの生成・更新を簡単に扱うためのモジュールです。
https://mixi.jp/connect_authorize.pl にアクセスすると認証codeが得られます。
その認証codeによりアクセストークン/リフレッシュトークンを取得します。
事前にサービスを登録し、Consumer keyとConsumer secretを入手しておいてください。

=head1 CLASS METHOD

=head2 lookup( $code )

認証codeで取得し、DBなどに保存したアクセストークン、リフレッシュトークンを取得し、インスタンスを返します。
expireされている場合はrefreshを試みます。

=head2 create

https://mixi.jp/connect_authorize.pl にアクセスして得られる認証codeからアクセストークン、リフレッシュトークンを取得し、DBなどに保存します。

=head2 auth_url( $scope )

認証codeを取得するためのURLを生成します。
本メソッドで生成したURLにアクセスして得られる認証coceにより、アクセストークン/リフレッシュトークンを取得します。
$scopeはmixi Graph APIのドキュメントを参照ください。

=head1 OBJECT METHOD

=head2 refresh

アクセストークンの再発行を試みます。

=head2 is_expired

アクセストークンの期限が切れているかどうかを返します。

=head1 SEE ALSO

=over 4

=item MixiAPI::Token::Source::DB

取得したアクセストークン/リフレッシュトークンをDB(MySQL, SQLiteなど)へ保存・取得するためのモジュールです。

=item mixi Developer Center

http://developer.mixi.co.jp/connect/mixi_graph_api

=back

=head1 AUTHOR

Souta.Nakamori

=cut
