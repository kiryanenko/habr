package Local::Config;

use strict;
use warnings;

=encoding utf8

=head1 NAME

Local::Habr - habrahabr.ru crawler

=head1 VERSION

Version 1.00

=cut

our $VERSION = '1.00';

=head1 SYNOPSIS

=cut

our @db = (
	'dbi:Pg:dbname=habr;host=localhost;port=5432',
	'perl',
	'123456'
);

our %memcach = (
	servers => [ '127.0.0.1:11211' ],
	namespace => 'my:',
	connect_timeout => 0.2,
);

1;
