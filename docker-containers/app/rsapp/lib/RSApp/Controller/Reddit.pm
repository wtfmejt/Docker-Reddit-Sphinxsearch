package RSApp::Controller::Reddit;
use Mojo::Base 'Mojolicious::Controller';
use strict;
use warnings;
use Data::Dumper;
use Math::BaseCnv;
use Text::Markdown 'markdown';
use HTML::Entities;
use Cpanel::JSON::XS;
use Time::HiRes 'time';
use DBI;
$|=1;

sub searchAuthor {
my $self = shift;
my $dbh = getDBHandle();
my $sphinx = getSphinxHandle();
my $query = $dbh->prepare(qq|
SELECT id, count(*) c, submission_id, subreddit_id, score FROM rt
WHERE match(?) GROUP BY submission_id
WITHIN GROUP ORDER BY score DESC
ORDER BY c DESC
LIMIT ?
|);
}

sub searchComments {
my $self = shift;
my $limit = $self->param('limit') ? int $self->param('limit') : 25;
if ($limit > 100) {$limit = 100}
my $results = $self->sphinx->db->query("SELECT * FROM rt WHERE match(?) ORDER BY date DESC LIMIT ?",$self->param('q'),$limit)->hashes;
$self->render(json => $results);
}


sub search {
my $self = shift;
my $data;
$data->{data} = undef;
my $limit = $self->param('limit') ? int $self->param('limit') : 25;
if ($limit > 100) {$limit = 100}
my $query = qq|
SELECT id, count(*) c, submission_id, subreddit_id, score FROM rt 
WHERE match(?) GROUP BY submission_id
WITHIN GROUP ORDER BY score DESC
ORDER BY c DESC
LIMIT ?|;

my $time = time;
my $results = $self->sphinx->db->query($query,$self->param('q'),$limit)->hashes;
$data->{debug}->{sphinxtime} = time - $time;

# Get SphinxSearch Data
#$query = $self->sphinx->prepare(qq|SHOW META|);
#$query->execute();
#my $arr_ref2 = $query->fetchall_arrayref({});
#my $hash_ref;
#for (@$arr_ref2) {
#    my $value = $_->{'Value'} =~ /^[\.\d]+$/ ? $_->{'Value'}+0 : $_->{'Value'};
#    $hash_ref->{$_->{'Variable_name'}} = $value;
#    }
#$data->{debug}->{'meta'} = $hash_ref;
$self->render(json => $results);
#$dbh->disconnect;
}


1;
