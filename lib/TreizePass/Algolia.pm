package TreizePass::Algolia;
use Mojo::Base -base;
use Mojo::UserAgent;

our $VERSION = '0.01';

has 'ua' => sub {Mojo::UserAgent->new} ;
has app_id => sub { $ENV{ALGOLIA_APPLICATION_ID} };
has app_key => sub { $ENV{ALGOLIA_API_KEY} };
has headers => sub { {} };

sub set_headers {
  my ($self, $headers ) = @_;
  if ($headers)
  {
    $self->headers = $headers;
  }else
  {
    $self->headers->{'Content-Type'} = "application/json; charset=utf-8";
    $self->headers->{'X-Algolia-Application-Id'} = $self->app_id;
    $self->headers->{'X-Algolia-API-Key'} = $self->app_key;
  }

  return $self->headers;
}

sub api_query {
  my ($self, $method, $request_path, $body) = @_;
  unless ($self->headers->{'X-Algolia-API-Key'}) {
    $self->set_headers();
  }
  my $tx;
  if($body)
  {
    $tx = $self->ua->build_tx($method => 'https://'.$self->app_id.'.algolia.io'.$request_path => $self->headers => json => $body);
  }else{
    $tx = $self->ua->build_tx($method => 'https://'.$self->app_id.'.algolia.io'.$request_path => $self->headers);
  }
  $tx = $self->ua->start($tx);
  if (my $res = $tx->success) { 
    return $res->json; 
  }else
  {
    if ($tx->res->code ~~ [ 400,403,404 ])
    {
      return $tx->res->code;
    }else
    {
      return { "error" => $tx->res, request => $tx->req };
    }
  }
}

sub wait_task {
  my ($self, $index_name, $task_id,$delay) = @_;
  $delay = $delay || 5;
  my $status ='notPublished';
  my $get_result;
  while ($status ne 'published')
  {
    sleep($delay);
    $get_result = $self->api_query('GET',"/1/indexes/$index_name/task/".$task_id);
    $status = $get_result->{status};
  }  
}

1;
