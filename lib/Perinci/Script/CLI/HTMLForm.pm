package Perinci::Script::CLI::HTMLForm;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

use Mo qw(build default);
extends 'Perinci::Script::Base';

sub BUILD {
    my ($self, $args) = @_;

    if (!$self->{riap_client}) {
        require Perinci::Access::Lite;
        my %rcargs = (
            riap_version => $self->{riap_version} // 1.1,
            %{ $self->{riap_client_args} // {} },
        );
        $self->{riap_client} = Perinci::Access::Lite->new(%rcargs);
    }
}

sub run {
    require Borang::HTML;

    my ($self) = @_;

    my $r = {};
    my $meta = $self->get_meta($r, $self->url);

    my $res = Borang::HTML::gen_html_form(
        meta => $meta,
        meta_is_normalized => 1,
        # values => { ... },
    );

    print $res;
}

1;
# ABSTRACT: Run functions described by Rinci as CLI (with HTML form as UI)

=head1 SEE ALSO

L<Perinci::Script>
