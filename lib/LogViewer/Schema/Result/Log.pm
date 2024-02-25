use utf8;
package LogViewer::Schema::Result::Log;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LogViewer::Schema::Result::Log

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<log>

=cut

__PACKAGE__->table("log");

=head1 ACCESSORS

=head2 created

  data_type: 'timestamp'
  is_nullable: 0
  size: 0

=head2 int_id

  data_type: 'char'
  is_nullable: 0
  size: 16

=head2 str

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 address

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=cut

__PACKAGE__->add_columns(
  "created",
  { data_type => "timestamp", is_nullable => 0, size => 0 },
  "int_id",
  { data_type => "char", is_nullable => 0, size => 16 },
  "str",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "address",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
);


# Created by DBIx::Class::Schema::Loader v0.07052 @ 2024-02-25 13:25:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:t5o6cBsYPbbNvacBWQyLyw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
