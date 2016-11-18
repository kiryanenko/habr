use FindBin;
use lib "$FindBin::Bin/../lib";
use Local::Config;
use My::Schema;
my $schema = My::Schema->connect( @Local::Config::db );
$schema->deploy();
