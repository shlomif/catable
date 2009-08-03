package App::Catable::Controller::Blog;

use strict;
use warnings;
use base 'Catalyst::Controller::HTML::FormFu';

=head1 NAME

App::Catable::Controller::Blog - For multiple blogs

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 load_blog

Gets the blog name from the URL and stashes the Row object.

=cut

sub load_blog : Chained PathPart('blog') CaptureArgs(1) {
    my ($self, $c, $blog_name) = @_;
   
    $c->stash->{blog} = 
        $c->model('BlogDB')->resultset('Blog')->single({ url => $blog_name});

    $c->log->debug( sprintf " load_blog found blog ID %d", $c->stash->{blog}->id );

    return;
}

1;

__END__

=head1 AUTHOR

Alastair Douglas L<www.grammarpolice.co.uk>

=head1 LICENSE

This library is distributed under the MIT/X11 License: 

L<http://www.opensource.org/licenses/mit-license.php>

=cut

