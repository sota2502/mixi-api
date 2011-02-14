package MixiAPI::Token::Source::DB;
use strict;
use warnings;

use base qw/
    MixiAPI::Token::Source::Base
    DBIx::Class::Schema::Loader
/;

use MixiAPI::Constants;
use Carp;


__PACKAGE__->loader_options(
#     debug => 1,
);


sub _resultset {
    my $class = shift;
    my $schema = $class->connect(
        MixiAPI::Constants->DB_DSN,
        MixiAPI::Constants->DB_USER,
        MixiAPI::Constants->DB_PASSWORD,
    );
    return $schema->resultset('Token');
}

sub insert {
    my ($class, %args) = @_;

    my $ret;
    eval {
        my %params = map {
            ($_ => $args{$_})
        } qw/code access_token refresh_token expire/;
        $ret = $class->_resultset->create(\%params);
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
        my $row = $class->_resultset->find($args{code});
        return undef unless ( $row );


        my %params = map {
            ($_ => $args{$_})
        } qw/access_token refresh_token expire/;
        $ret = $row->update(\%params);
    };
    if( $@ ) {
        Carp::croak( 'fail update:'.  $@ );
    }

    return $ret;
}

sub select {
    my ($class, %args) = @_;

    my $row;
    eval {
        $row = $class->_resultset->find($args{code});
    };
    if( $@ ) {
        Carp::croak( 'fail select:'.  $@ );
    }

    return unless ( $row );

    return {
        code          => $row->code,
        access_token  => $row->access_token,
        refresh_token => $row->refresh_token,
        expire        => $row->expire,
    };
}


1;
