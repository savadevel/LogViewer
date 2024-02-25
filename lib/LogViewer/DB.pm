use utf8;
package LogViewer::DB;

use strict;
use warnings FATAL => 'all';
use LogViewer::Schema;

use constant DSN_DB => "dbi:Pg:dbname=log_viewer;host=db;port=5432";
use constant USER_DB => "user";
use constant PASS_DB => "pass";

my $dbh;

# dbh - класс-синглтон для подключения к базе данных
sub dbh {
    $dbh = (
        $dbh
            || LogViewer::Schema->connect(DSN_DB, USER_DB, PASS_DB, { AutoCommit => 1, RaiseError => 1, PrintError => 1 })
            || die $DBI::errstr);
}

1;