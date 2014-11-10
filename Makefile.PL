use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'TreizePass::Algolia',
  VERSION_FROM => 'lib/TreizePass/Algolia.pm',
  AUTHOR       => '13 pass <contact@13pass.com>',
  BUILD_REQUIRES => {
    'Test::More'              => '0.94',
  },
  PREREQ_PM    => {'Mojolicious' => '4'},
  test         => {TESTS => 't/*.t'}
);
