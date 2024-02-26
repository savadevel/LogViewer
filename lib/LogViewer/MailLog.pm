package LogViewer::MailLog;

# Класс-синглтон для загрузки файла почтового лога.
# Загрузка файла почтового лога, только при первом вызове instance().
# После загрузки очередного сообщения, формируются сообщения для события / вызываются через обратный вызов:
#   on_message - "прибытие сообщения"
#   on_log - "нормальная доставка", "дополнительный адрес", "доставка не удалась", "доставка задержана"
#   on_information - "общая информация"

use strict;
use warnings FATAL => 'all';

use base 'Class::Singleton';

# подключаем Dancer2 для использования параметров из config.yml
use Dancer2;
use DateTime;
use Try::Tiny;

use LogViewer::Utils;

use constant FLAGS =>
    {
        '<='          => # прибытие сообщения (в этом случае за флагом следует адрес отправителя)
            \&_on_message,
        '=>'          => # нормальная доставка сообщения
            \&_on_log,
        '->'          => # дополнительный адрес в той же доставке
            \&_on_log,
        '**'          => # доставка не удалась
            \&_on_log,
        '=='          => # доставка задержана (временная проблема)
            \&_on_log,
        'information' => # В случаях, когда в лог пишется общая информация, флаг и адрес получателя не указываются
            \&_on_information,
    };

our $VERSION = '0.1';

sub _new_instance {
    my $class = shift;
    my $self = bless { @_ }, $class;

    $self->_load_log_file_to_db();

    return $self;
}

sub _load_log_file_to_db {
    my $self = shift;
    my $fh = undef;
    try {
        open($fh, '<', setting('file_log')) or die setting('file_log') . ' ' . $!;
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
                FLAGS->{$flag}($self, $date_time, $int_id, $raw_address, $log);
                next;
            }
            FLAGS->{information}($self, $date_time, $int_id, $log);
        }
    }
    catch {
        warn("caught error: $_");
    }
    finally {
        close($fh) if defined $fh;
    };
}
sub _on_message {
    my ($self, $date_time, $int_id, $raw_address, $log) = @_;
    my $id = _extract_id($log);

    return _on_log($self, $date_time, $int_id, $raw_address, $log) unless (defined $id);

    my $address = LogViewer::Utils::extract_address($raw_address);
    $self->{on_message}($self, $date_time, $int_id, $id, $address, $log) if (defined($self->{on_message}));
}

sub _extract_id {
    my ($id) = (shift =~ /id=(\S{1,})/);
    return $id;
}

sub _on_log {
    my ($self, $date_time, $int_id, $raw_address, $log) = @_;
    my $address = LogViewer::Utils::extract_address($raw_address);
    $self->{on_log}($self, $date_time, $int_id, $address, $log) if (defined($self->{on_log}));
}

sub _on_information {
    my ($self, $date_time, $int_id, $log) = @_;
    # В случаях, когда в лог пишется общая информация, флаг и адрес получателя не указываются
    # поэтому передаем undef для записи информации в таблицу Log
    $self->{on_information}($self, $date_time, $int_id, undef, $log) if (defined($self->{on_information}));
}

1;