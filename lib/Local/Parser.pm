package Local::Parser;

use LWP::UserAgent;
use HTML::DOM;

sub user {
	my $name = shift;
	
	my $response = LWP::UserAgent->new()->get("http://habrahabr.ru/users/$name/");
	if ($response->is_success()) {
		my $dom_tree = new HTML::DOM;
		$dom_tree->write($response->decoded_content);
  		$dom_tree->close;

  		my $karma = $dom_tree->getElementsByClassName('voting-wjt__counter-score js-karma_num')->[0]->as_text;
  		my $rating = $dom_tree->getElementsByClassName('statistic__value statistic__value_magenta')->[0]->as_text;

  		if (defined $karma && defined $rating) {
	  		return { name => $name, karma => $karma, rating => $rating };
		}
	}
	return;
}

sub post {
	my $post = shift;

	my $response = LWP::UserAgent->new()->get("http://habrahabr.ru/post/$post/");
	if ($response->is_success()) {
		my $dom_tree = new HTML::DOM;
		$dom_tree->write($response->decoded_content);
  		$dom_tree->close;

		$dom_tree->getElementsByClassName('author-info__nickname')->[0]->as_text =~ /@(\w+)/;
		my $author = $1;
		my $theme = $dom_tree->getElementsByClassName('post__title')->[0]->getElementsByTagName('span')->[1]->as_text;
  		my $views = $dom_tree->getElementsByClassName('views-count_post')->[0]->as_text;
  		my $rating = $dom_tree->getElementsByClassName('js-score')->[0]->as_text;

  		if ( defined $author && defined $theme && defined $views && defined $rating ) {
	  		# Комментаторы
	  		my @commenters = map { $_->as_text; } $dom_tree->getElementsByClassName('comment-item__username');
  			
  			return {
	  			post_id => $post,
	  			author => $author,
	  			theme => $theme,
	  			views => $views, 
	  			rating => $rating,
	  			commenters => \@commenters
	  		};
		}
	}
	return;
}

1;
