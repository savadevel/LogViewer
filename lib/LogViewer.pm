use utf8;
package LogViewer;

use Dancer2;

use Try::Tiny;
use LogViewer::DB;
use LogViewer::Utils;

use constant LIMIT_ROWS => 100;

our $VERSION = '0.1';

prefix undef;
set content_type => 'text/html';

get '/' => sub {
    template 'index';
};

get '/addresses' => sub {
    my $address = param('address');
    unless (is_valid_address($address)) {
        send_error "Bad address: '$address'" => 400;
    }

    my $dbh = LogViewer::DB->dbh;
    my $rows = [ $dbh->resultset('MessageAndLog')
        ->search(
        {},
        {
            bind => [ $address, $address ],
            rows => LIMIT_ROWS + 1,
            result_class => 'DBIx::Class::ResultClass::HashRefInflator'
        })
        ->all() ];

    template 'index.tt', {
        limit_rows => LIMIT_ROWS,
        rows       => $rows
    };
};

true;
