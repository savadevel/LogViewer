package LogViewer::DB;

# класс-синглтон для подключения к базе данных
# создание одного подключения, только при первом вызове instance()

use strict;
use warnings FATAL => 'all';

use base 'Class::Singleton';

use LogViewer::Schema;

use constant DSN_DB => "dbi:Pg:dbname=log_viewer;host=db;port=5432";
use constant USER_DB => "user";
use constant PASS_DB => "pass";

sub _new_instance {
    my $class = shift;
    my $self = bless {}, $class;

    $self->{dbh} = LogViewer::Schema->connect(DSN_DB, USER_DB, PASS_DB, { AutoCommit => 1, RaiseError => 1, PrintError => 1 })
        || die "Cannot connect to database: $DBI::errstr";

    return $self;
}

sub dbh {
    return shift->{dbh};
}

sub DESTROY {
    shift->{dbh}->disconnect if (defined(shift->{dbh}));
}

1;