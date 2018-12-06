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
    require Browser::Open;
    require Perinci::Sub::GetArgs::WebForm;
    require Plack::Request;
    require Plack::Runner;
    require Port::Selector;

    my ($self) = @_;

    my $port = Port::Selector->new->port;
    my $server_url = "http://localhost:$port/";

    my $app = sub {
        my $env = shift;

        my $preq = Plack::Request->new($env);
        my $pres = $preq->new_response(200);
        $pres->content_type('text/html');

        my @c;

        use DD; dd $preq->parameters;

        my $r = {};
        my $meta = $self->get_meta($r, $self->url);

        my $args = Perinci::Sub::GetArgs::WebForm::get_args_from_webform(
            $preq->parameters,
            $meta,
            1,
        );

        if ($preq->parameters->{_submit}) {
            my $res = $self->riap_client->request(call => $self->url, {args=>$args});
            push @c, $res->[2];
        } else {
            my $form = Borang::HTML::gen_html_form(
                action => "$server_url?_submit=1",
                meta => $meta,
                meta_is_normalized => 1,
                # values => { ... },
            );
            push @c, $form;
        }

      RETURN_RES:
        $pres->body(join "", @c);
        $pres->finalize;
    };

    my $runner = Plack::Runner->new;
    $runner->parse_options("--host", "localhost", "--port", $port);
    $runner->run($app);
}

1;
# ABSTRACT: Run functions described by Rinci as CLI (with HTML form as UI)

=head1 SEE ALSO

L<Perinci::Script>
