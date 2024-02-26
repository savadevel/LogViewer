package LogViewer::DB;

# класс-синглтон для подключения к базе данных
# создание одного подключения, только при первом вызове instance()

use strict;
use warnings FATAL => 'all';

use base 'Class::Singleton';

# подключаем Dancer2 для использования параметров из config.yml
use Dancer2;

use LogViewer::Schema;

our $VERSION = '0.1';

sub _new_instance {
    my $class = shift;
    my $self = bless {}, $class;

    $self->{dbh} = LogViewer::Schema->connect(setting('db_dsn'), setting('db_user'), setting('db_pass'),
        { AutoCommit => 1, RaiseError => 1, PrintError => 1 })
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