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

=begin Removed

sub load_blog : Chained PathPart('blog') CaptureArgs(1) {
    my ($self, $c, $blog_name) = @_;
   
    $c->stash->{blog} = 
        $c->model('BlogDB')->resultset('Blog')->single({ url => $blog_name});

    $c->log->debug( sprintf " load_blog found blog ID %d", $c->stash->{blog}->id );

    return;
}

=end Removed

=cut

=head2 $self->create_blog($c)

Creates a new blog. Handles the '/create-blog' URL - accepts no arguments and 
ends the chain.

=cut

sub create_blog : Path('/create-blog') Args(0) FormConfig
{
    my ($self, $c) = @_;

    my $form = $c->stash->{form};

    $c->stash->{template} = "create-blog.tt2";
    $c->stash->{'submitted'} = 0;

    if ($form->submitted_and_valid)
    {
        my $params = $form->params;

        $c->model('BlogDB')->resultset('Blog')
            ->create(
                {
                    (map 
                        { $_ => $params->{$_} }
                        (qw(url title))
                    ),
                    theme => "catable",
                    owner => $c->user->id(),
                }
            );

        $c->stash->{'submitted'} = 1;
        $c->stash->{'url'} = $params->{'url'};
    }

    return;
}

1;

__END__

=head1 AUTHOR

Alastair Douglas L<http://www.grammarpolice.co.uk/>

=head1 LICENSE

This library is distributed under the MIT/X11 License: 

L<http://www.opensource.org/licenses/mit-license.php>

=cut

