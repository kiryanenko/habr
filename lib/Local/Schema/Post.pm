package Local::Schema::Post;
use base qw(DBIx::Class::Core);

__PACKAGE__->table('post');
__PACKAGE__->add_columns(
	id => {
		data_type => 'integer',
	},
	author => {
		data_type => 'integer',
	},
	theme => {
		data_type => 'varchar',
		size => '100',
	},
	rating => {
		data_type => 'integer',
	},
	views => {
		data_type => 'integer',
	}
	stars => {
		data_type => 'integer',
	}
);
__PACKAGE__->belongs_to(
	author => 'Local::Schema::User', 'user_id'
);

1;
