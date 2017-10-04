#!/usr/bin/perl

use warnings;
use strict;

use Data::Dumper;

my %peers = ();
my %templates = ();
my $state = undef;


my $peer_name;
my $callerid;

my $peer = {};

sub apply_templates {
        my ($peer, $t_names) = @_;
        foreach my $t (@{$t_names}) {
                foreach my $param (keys %{$templates{$t}})       {
                        next if $param eq 'is_template';
                        next if $param eq 'username';
                        next if $param eq 'templates';
                        next if $param eq 'name';
                        $peer->{$param} = $templates{$t}->{$param};
                }
        }
}


while(<>) {
#       print $_;
        chomp;

        next if /\s*?;.*/;

        if (/\[(.*)\](\(.*\))?/) {
                #already have current peer, so can store it since next peer is started
                if ($peer->{'name'}) {
                        if ($peer->{'is_template'}) {
                                $templates{$peer->{'name'}} = $peer;
                        } else {
                                if ($peer->{'username'}) {
                                        $peers{$peer->{'username'}} = $peer;
                                } else {
                                        $peers{$peer->{'name'}} = $peer;
                                }
                        }

                }
                                $peer = {};
                $peer->{'name'} = $1;
                $peer->{'username'} = $1;
                my $template_names = $2;

                next unless $template_names;

                #Peer definition is template itself
                $template_names =~ s/\((.*)\)/$1/;

                my @peer_templates = split(/\s*,\s*/, $template_names);

                if ( grep (/\!/,@peer_templates)) {
                        $peer->{'is_template'}=1;
                }

                $peer->{'templates'} = \@peer_templates;

                apply_templates($peer,\@peer_templates);

                next;
        }

        #This seem to be a peer body

        if (/callerid.*?=.*?<(.*)>/) {
                $peer->{'callerid'}=$1;
        }
        if (/username\s*?=\s*(.*);*/) {
                $peer->{'username'}=$1;
        }
        if (/secret\s*?=\s*(.*);*/) {
                $peer->{'secret'}=$1;
        }
        if (/host\s*?=\s*(.*);*/) {
                $peer->{'host'}=$1;
        }

        if (/context\s*?=\s*(.*);*/) {
                $peer->{'context'}=$1;
        }
               if (/permit\s*?=\s*(.*);*/) {

                if ($peer->{'permit'}) {
                        $peer->{'permit'}=$peer->{'permit'}.",".$1;
                } else {
                        $peer->{'permit'}=$1;
                }
        }

        if (/deny\s*?=\s*(.*);*/) {

                if ($peer->{'deny'}) {
                        $peer->{'deny'}=$peer->{'deny'}.",".$1;
                } else {
                        $peer->{'deny'}=$1;
                }
        }
        if (/nat\s*?=\s*(.*);*/) {
                $peer->{'nat'}=$1;
        }

        if (/dtmfmode\s*?=\s*(.*);*/) {
                $peer->{'dtmfmode'}=$1;
        }

        if (/t38pt_udptl\s*?=\s*(.*);*/) {
                $peer->{'t38pt_udptl'}=$1;
        }

}

$peers{$peer->{'name'}} = $peer;
#print Dumper(\%peers);


no warnings qw(uninitialized);
foreach(keys %peers) {
        my $p = $peers{$_};
        printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n",
                        $p->{'username'},
                        $p->{'secret'},
                        $p->{'host'},
                        $p->{'context'},
                        $p->{'deny'},
                        $p->{'permit'},
                        $p->{'t38pt_udptl'};
}


