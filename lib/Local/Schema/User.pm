package Local::Schema::User;
use base qw(DBIx::Class::Core);

__PACKAGE__->table('user');
__PACKAGE__->add_columns(
	id => {
		data_type => 'integer',
		is_auto_increment => 1,
	},
	name => {
		data_type => 'varchar',
		size => '100',
	},
	karma => {
		data_type => 'integer',
	},
	rating => {
		data_type => 'integer',
	}
);
__PACKAGE__->has_many(
	posts => 'Local::Schema::Post','user_id'
);

1;
