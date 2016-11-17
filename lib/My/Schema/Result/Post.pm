use utf8;
package My::Schema::Result::Post;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

My::Schema::Result::Post

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<posts>

=cut

__PACKAGE__->table("posts");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'user_ids'

=head2 author

  data_type: 'integer'
  is_nullable: 1

=head2 theme

  data_type: 'char'
  is_nullable: 1
  size: 100

=head2 rating

  data_type: 'integer'
  is_nullable: 1

=head2 views

  data_type: 'integer'
  is_nullable: 1

=head2 stars

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "author",
  { data_type => "integer", is_nullable => 1 },
  "theme",
  { data_type => "char", is_nullable => 1, size => 100 },
  "rating",
  { data_type => "integer", is_nullable => 1 },
  "views",
  { data_type => "integer", is_nullable => 1 },
  "stars",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->belongs_to(
	author => 'My::Schema::Result::User', 'id'
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-11-15 23:41:49
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pUGaOE+zvyZoA+Y40EYl8g


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
