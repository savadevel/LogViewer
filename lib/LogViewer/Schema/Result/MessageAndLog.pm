package LogViewer::Schema::Result::MessageAndLog;
use strict;
use warnings FATAL => 'all';

use base qw/DBIx::Class::Core/;

__PACKAGE__->load_components('InflateColumn::DateTime');
__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table('MessageAndLog');
# do not attempt to deploy() this view
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(q[
select t.created, t.str
from (select l.created, l.str, l.int_id
      from log l
      where l.address = ?
      union all
      select m.created, m.str, m.int_id
      from message m
      where m.address = ?) t
order by t.created, t.int_id
]);

__PACKAGE__->add_columns(
    "created",
    {
        data_type   => "timestamp",
        is_nullable => 0,
        size        => 0 },
    "str",
    {
        data_type   => "text",
        is_nullable => 0,
        original    => { data_type => "varchar" },
    },
);

1;