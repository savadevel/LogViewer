package LogViewer::Utils;

# Общие функции используемые в приложении:
# init_app - инициализация приложения (создание структуры таблиц, загрузка почтового лога)
# is_valid_address - проверка что переданная строка в формате адреса эл. почты
# extract_address - извлекает адреса эл. почты из переданной строки
use strict;
use warnings FATAL => 'all';

use parent 'Exporter';

use DateTime;
use Try::Tiny;

use Email::Address;
use LogViewer::DB;
use LogViewer::MailLog;

use constant DEFAULT_STATUS => 1;

our @EXPORT = qw/extract_address init_app is_valid_address/;our @EXPORT_OK = qw/extract_address init_app is_valid_address/;

# инициализация приложения (создание структуры таблиц, загрузка почтового лога)
sub init_app {
    my $dbh = LogViewer::DB->instance->dbh;
    # создаем требуемую структуру объектов по ORM (auto_drop_tables не работает для PG)
    $dbh->deploy( { auto_drop_tables => 1 } );

    # подписка на события загрузки почтового лога,
    # пишем в БД, при срабатывании события
    LogViewer::MailLog->instance(
        on_message      => \&_put_to_tbl_message,
        on_log          => \&_put_to_tbl_log,
        on_information  => \&_put_to_tbl_log,
    );
}

sub _put_to_tbl_message {
    my ($mail_log, $date_time, $int_id, $id, $address, $log) = @_;
    my $dbh = LogViewer::DB->instance->dbh;
    my $rs = $dbh->resultset('Message');
    try {
        $rs->create({
            created => $date_time,
            id      => $id,
            int_id  => $int_id,
            str     => $log,
            status  => DEFAULT_STATUS,
            address => $address
        });
    }
    catch {
        warn("Error put row to table 'Message': $_");
    }
}

sub _put_to_tbl_log {
    my ($mail_log, $date_time, $int_id, $address, $log) = @_;
    my $dbh = LogViewer::DB->instance->dbh;
    my $rs = $dbh->resultset('Log');
    try {
        $rs->create({
            created => $date_time,
            int_id  => $int_id,
            str     => $log,
            address => $address
        });
    }
    catch {
        warn("Error put row to table 'Log': $_");
    }
}

# проверка что переданная строка в формате адреса эл. почты
# возвращает true если адрес в формате эл. почты
sub is_valid_address {
    return defined extract_address(shift);
}

# извлекает адреса эл. почты из переданной строки
# возвращает адрес в формате эл. почты,
# возвращает undef если стока не содержит адреса эл. почты
sub extract_address {
    my @addresses = Email::Address->parse(shift);
    return undef if (1 != scalar(@addresses));
    return $addresses[0]->address;
}

1;