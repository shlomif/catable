package App::Catable::Controller::Posts;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

App::Catable::Controller::Posts - Catalyst Posts Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 add

Add a post.

=cut

sub add : Local {
    # Retrieve the usual Perl OO '$self' for this object. $c is the Catalyst
    # 'Context' that's used to 'glue together' the various components
    # that make up the application
    my ($self, $c) = @_;

    # Retrieve all of the book records as book model objects and store in the
    # stash where they can be accessed by the TT template
    # $c->stash->{books} = [$c->model('DB::Book')->all];
    # But, for now, use this code until we create the model later
    $c->stash->{books} = '';

    # Set the TT template to use.  You will almost always want to do this
    # in your action methods (action methods respond to user input in
    # your controllers).
    $c->stash->{template} = 'posts/add.tt2';
}

=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;

    $c->response->body('Matched App::Catable::Controller::Posts in Posts.');
}

=head1 AUTHOR

Shlomi Fish, L<http://www.shlomifish.org/>

=head1 LICENSE

This library is distributed under the MIT/X11 License: 

L<http://www.opensource.org/licenses/mit-license.php>

=cut

1;
