use utf8;
package LogViewer::Schema::Result::Message;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

LogViewer::Schema::Result::Message

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<message>

=cut

__PACKAGE__->table("message");

=head1 ACCESSORS

=head2 created

  data_type: 'timestamp'
  is_nullable: 0
  size: 0

=head2 id

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 int_id

  data_type: 'char'
  is_nullable: 0
  size: 16

=head2 str

  data_type: 'text'
  is_nullable: 0
  original: {data_type => "varchar"}

=head2 address

  data_type: 'text'
  is_nullable: 1
  original: {data_type => "varchar"}

=head2 status

  data_type: 'boolean'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "created",
  { data_type => "timestamp", is_nullable => 0, size => 0 },
  "id",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "int_id",
  { data_type => "char", is_nullable => 0, size => 16 },
  "str",
  {
    data_type   => "text",
    is_nullable => 0,
    original    => { data_type => "varchar" },
  },
  "address",
  {
    data_type   => "text",
    is_nullable => 1,
    original    => { data_type => "varchar" },
  },
  "status",
  { data_type => "boolean", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07052 @ 2024-02-25 13:25:18
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ctUB45ousuS7sNIdxFlZ+w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
