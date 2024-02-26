package LogViewer;

# класс-контролер, обрабатывает запросы пользователя,
# направляемые им через web форму

use Dancer2;
use Try::Tiny;

use LogViewer::DB;
use LogViewer::Utils;
use LogViewer::MailLog;

our $VERSION = '0.1';

prefix undef;
set content_type => 'text/html';

# инициализация приложения
{
    init_app();
}

# web форма для запроса
get '/' => sub {
    template('index');
};

# результат запроса по адресу
get '/addresses' => sub {
    my $address = param('address');
    # адрес должен быть в формате эл. почты
    unless (is_valid_address($address)) {
        send_error "Bad address: '$address'" => 400;
    }

    my $dbh = LogViewer::DB->instance->dbh;
    my $rows = [ $dbh->resultset('MessageAndLog')
        ->search(
        {},
        {
            bind => [ $address, $address ],
            rows => setting('limit_rows') +1,
                result_class => 'DBIx::Class::ResultClass::HashRefInflator'
        })
        ->all() ];

    template('index.tt', {
        limit_rows => setting('limit_rows'),
        rows       => $rows
    });
};

true;
