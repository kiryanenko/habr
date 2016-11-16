use utf8;
package My::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

My::Schema::Result::User

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'user_ids'

=head2 name

  data_type: 'char'
  is_nullable: 1
  size: 64

=head2 karma

  data_type: 'integer'
  is_nullable: 1

=head2 rating

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "user_ids",
  },
  "name",
  { data_type => "char", is_nullable => 1, size => 64 },
  "karma",
  { data_type => "integer", is_nullable => 1 },
  "rating",
  { data_type => "integer", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-11-15 23:41:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:F6JlRknPmL95Mn+i0TNWlQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
