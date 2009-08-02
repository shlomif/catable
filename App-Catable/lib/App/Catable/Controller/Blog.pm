package App::Catable::Controller::Blog;

use strict;
use warnings;
use base 'Catalyst::Controller::HTML::FormFu';

=head1 NAME

App::Catable::Controller::Blog - For multiple blogs

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 get_blog

Gets the blog name from the URL and stashes the Row object.

=cut

sub get_blog : Local Path('') CaptureArgs(1) {
    my ($self, $c, $blog_name) = @_;
   
    $c->stash->{blog} = 
        $c->model('BlogDB')->resultset('Blog')->single({ name => $blog_name});
}

1;

__END__

