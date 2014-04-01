package Dist::Zilla::Plugin::SHARYANTO::OurPkgVersion;

use 5.010;
use strict;
use warnings;

our $VERSION = '0.02'; # VERSION

use Moose;
with (
	'Dist::Zilla::Role::FileMunger',
	'Dist::Zilla::Role::FileFinderUser' => {
		default_finders => [ ':InstallModules', ':ExecFiles' ],
	},
);

use namespace::autoclean;

sub munge_files {
	my $self = shift;

	$self->munge_file($_) for @{ $self->found_files };
	return;
}

sub munge_file {
	my ( $self, $file ) = @_;

	if ( $file->name =~ m/\.pod$/ixms ) {
		$self->log_debug( 'Skipping: "' . $file->name . '" is pod only');
		return;
	}

	my $version = $self->zilla->version;

	my $content = $file->content;

        my $munged_version = 0;
        $content =~ s/
                  ^
                  (\s*)           # capture all whitespace before comment

                  (?:our [ ] \$VERSION [ ] = [ ] 'v?[0-9_.]+'; [ ] )?  # previously produced output
                  (
                    \#\s*VERSION  # capture # VERSION
                    \b            # and ensure it ends on a word boundary
                    [             # conditionally
                      [:print:]   # all printable characters after VERSION
                      \s          # any whitespace including newlines see GH #5
                    ]*            # as many of the above as there are
                  )
                  $               # until the EOL}xm
		/
                    "${1}our \$VERSION = '$version'; $2"/emx and $munged_version++;

	if ( $munged_version ) {
		$self->log_debug([ 'adding $VERSION assignment to %s', $file->name ]);
                $file->content($content);
	}
	else {
		$self->log( 'Skipping: "'
			. $file->name
			. '" has no "# VERSION" comment'
			);
	}
	return;
}
__PACKAGE__->meta->make_immutable;
1;
# ABSTRACT: no line insertion and does Package version with our

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::Plugin::SHARYANTO::OurPkgVersion - no line insertion and does Package version with our

=head1 VERSION

version 0.02

=head1 SYNOPSIS

in dist.ini

	[SHARYANTO::OurPkgVersion]

in your modules

	# VERSION

or

	our $VERSION = '0.123'; # VERSION

=head1 DESCRIPTION

This module is like L<Dist::Zilla::Plugin::OurPkgVersion> but can replace the
previously generated C<our $VERSION = '0.123'; > bit. If the author of
OurPkgVersion thinks this is a good idea, then perhaps this module will be
merged with OurPkgVersion.

=for Pod::Coverage .+

=head1 SEE ALSO

L<Dist::Zill::Plugin::OurPkgVersion>

A simple script I'm using when testing: L<https://github.com/sharyanto/scripts/blob/master/fill-version-numbers-from-dist-ini>

Another approach: L<Dist::Zill::Plugin::RewriteVersion> and L<Dist::Zill::Plugin:::BumpVersionAfterRelease>

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Dist-Zilla-Plugin-SHARYANTO-OurPkgVersion>.

=head1 SOURCE

Source repository is at L<https://github.com/sharyanto/perl-Dist-Zilla-Plugin-SHARYANTO-OurPkgVersion>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Dist-Zilla-Plugin-SHARYANTO-OurPkgVersion>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
