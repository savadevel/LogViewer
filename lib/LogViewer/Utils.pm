use utf8;
package LogViewer::Utils;
use strict;
use warnings FATAL => 'all';

use Exporter qw/import/;

use DateTime;
use Try::Tiny;

use Email::Address;
use LogViewer::DB;

our @EXPORT = qw/load_log_file_to_db is_valid_address/;

use constant FILE_LOG => './logs/out';

use constant UNKNOWN_ADDRESS => undef;
use constant DEFAULT_STATUS => 1;

use constant FLAGS =>
    {
        '<='     => # прибытие сообщения (в этом случае за флагом следует адрес отправителя)
            \&_put_to_tbl_message,
        '=>'     => # нормальная доставка сообщения
            \&_put_delivery_msg_to_tbl_log,
        '->'     => # дополнительный адрес в той же доставке
            \&_put_delivery_msg_to_tbl_log,
        '**'     => # доставка не удалась
            \&_put_delivery_msg_to_tbl_log,
        '=='     => # доставка задержана (временная проблема)
            \&_put_delivery_msg_to_tbl_log,
        'common' => # В случаях, когда в лог пишется общая информация, флаг и адрес получателя не указываются
            \&_put_information_msg_to_tbl_log,
    };

sub load_log_file_to_db {
    my $dbh = LogViewer::DB->dbh;

    open(my $fh, '<', FILE_LOG) or die FILE_LOG . ' ' . $!;

    while (my $line = <$fh>) {
        chomp($line);

        my ($year, $mon, $day, $hour, $min, $sec, $log) = ($line =~ /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2}) (.*?)$/);
        my ($int_id) = ($log =~ /^([\S]{1,})/g);
        my ($flag, $raw_address) = ($log =~ / ([\S]{2}) ([\S]{1,})/g);
        my ($date_time) = DateTime->new(year => $year,
            month                            => $mon,
            day                              => $day,
            hour                             => $hour,
            minute                           => $min,
            second                           => $sec,
            time_zone                        => 'GMT',
        );

        if (defined $flag && defined FLAGS->{$flag}) {
            FLAGS->{$flag}($dbh, $date_time, $int_id, $raw_address, $log);
            next;
        }

        FLAGS->{common}($dbh, $date_time, $int_id, $log);
    }

    close $fh;
}

sub _put_to_tbl_message {
    my ($dbh, $date_time, $int_id, $raw_address, $log) = @_;
    my $id = _extract_id($log);

    return _put_delivery_msg_to_tbl_log($dbh, $date_time, $int_id, $raw_address, $log) unless (defined $id);

    my $address = _extract_address($raw_address);
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

sub is_valid_address {
    return defined _extract_address(shift);
}

sub _extract_address {
    my @addresses = Email::Address->parse(shift);
    return UNKNOWN_ADDRESS if (1 != scalar(@addresses));
    return $addresses[0]->address;
}

sub _extract_id {
    my ($id) = (shift =~ /id=(\S{1,})/);
    return $id;
}

sub _put_delivery_msg_to_tbl_log {
    my ($dbh, $date_time, $int_id, $raw_address, $log) = @_;
    my $address = _extract_address($raw_address);
    _put_to_tbl_log($dbh, $date_time, $int_id, $address, $log);
}

sub _put_to_tbl_log {
    my ($dbh, $date_time, $int_id, $address, $log) = @_;
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

sub _put_information_msg_to_tbl_log {
    my ($dbh, $date_time, $int_id, $log) = @_;
    _put_to_tbl_log($dbh, $date_time, $int_id, UNKNOWN_ADDRESS, $log);
}

1;