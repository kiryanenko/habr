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

=head2 rating

  data_type: 'char'
  is_nullable: 1
  size: 10

=head2 karma

  data_type: 'char'
  is_nullable: 1
  size: 8

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
  "rating",
  { data_type => "char", is_nullable => 1, size => 10 },
  "karma",
  { data_type => "char", is_nullable => 1, size => 8 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<users_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("users_name_key", ["name"]);

=head1 RELATIONS

=head2 commenters

Type: has_many

Related object: L<My::Schema::Result::Commenter>

=cut

__PACKAGE__->has_many(
  "commenters",
  "My::Schema::Result::Commenter",
  { "foreign.user_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 posts

Type: has_many

Related object: L<My::Schema::Result::Post>

=cut

__PACKAGE__->has_many(
  "posts",
  "My::Schema::Result::Post",
  { "foreign.author" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-11-18 06:03:19
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:DtRKYwylyOhbcRaw4YiqmA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
