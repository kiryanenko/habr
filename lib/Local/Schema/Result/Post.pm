use utf8;
package Local::Schema::Result::Post;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Local::Schema::Result::Post

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
  is_foreign_key: 1
  is_nullable: 1

=head2 theme

  data_type: 'char'
  is_nullable: 1
  size: 100

=head2 post_id

  data_type: 'integer'
  is_nullable: 1

=head2 rating

  data_type: 'char'
  is_nullable: 1
  size: 10

=head2 views

  data_type: 'char'
  is_nullable: 1
  size: 10

=head2 stars

  data_type: 'char'
  is_nullable: 1
  size: 10

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "user_ids",
  },
  "author",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "theme",
  { data_type => "char", is_nullable => 1, size => 100 },
  "post_id",
  { data_type => "integer", is_nullable => 1 },
  "rating",
  { data_type => "char", is_nullable => 1, size => 10 },
  "views",
  { data_type => "char", is_nullable => 1, size => 10 },
  "stars",
  { data_type => "char", is_nullable => 1, size => 10 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<posts_post_id_key>

=over 4

=item * L</post_id>

=back

=cut

__PACKAGE__->add_unique_constraint("posts_post_id_key", ["post_id"]);

=head1 RELATIONS

=head2 author

Type: belongs_to

Related object: L<Local::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "author",
  "Local::Schema::Result::User",
  { id => "author" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 commenters

Type: has_many

Related object: L<Local::Schema::Result::Commenter>

=cut

__PACKAGE__->has_many(
  "commenters",
  "Local::Schema::Result::Commenter",
  { "foreign.post_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-11-22 20:09:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IWccOsy6no+HVLJXXOC2Fg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
