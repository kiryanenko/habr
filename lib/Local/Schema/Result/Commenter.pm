use utf8;
package Local::Schema::Result::Commenter;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Local::Schema::Result::Commenter

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<commenters>

=cut

__PACKAGE__->table("commenters");

=head1 ACCESSORS

=head2 user_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 post_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "post_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);

=head1 UNIQUE CONSTRAINTS

=head2 C<commenters_user_id_post_id_key>

=over 4

=item * L</user_id>

=item * L</post_id>

=back

=cut

__PACKAGE__->add_unique_constraint("commenters_user_id_post_id_key", ["user_id", "post_id"]);

=head1 RELATIONS

=head2 post

Type: belongs_to

Related object: L<Local::Schema::Result::Post>

=cut

__PACKAGE__->belongs_to(
  "post",
  "Local::Schema::Result::Post",
  { id => "post_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);

=head2 user

Type: belongs_to

Related object: L<Local::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "user",
  "Local::Schema::Result::User",
  { id => "user_id" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07045 @ 2016-11-22 20:09:35
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IKS6n+knDvg9knq5s3CvmA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
