use Mojo::Base -strict;

use Test::More;
plan skip_all => 'set ALGOLIA_APPLICATION_ID and ALGOLIA_API_KEY to enable this test'
  unless ($ENV{ALGOLIA_APPLICATION_ID} || $ENV{ALGOLIA_API_KEY});

use TreizePass::Algolia;
is (1,1);
my $algolia = TreizePass::Algolia->new({
  app_id => $ENV{ALGOLIA_APPLICATION_ID}, 
  app_key => $ENV{ALGOLIA_API_KEY},
});

my $json_data = $algolia->api_query('GET','/1/indexes');
if ($json_data->{items}[0])
{
  my $object = { name => 'Eyjafjallajökull' } ;
  my $post_result = $algolia->api_query('POST','/1/indexes/'.$json_data->{items}[0]->{name},$object);
  if ($post_result->{taskID})
  {
    my $get_result;
    $algolia->wait_task($json_data->{items}[0]->{name},$post_result->{taskID});
    $get_result = $algolia->api_query('GET','/1/indexes/'.$json_data->{items}[0]->{name}.'/'.$post_result->{objectID});
    ok($object->{name} eq $get_result->{name});
    
    my $delete_result = $algolia->api_query('DELETE','/1/indexes/'.$json_data->{items}[0]->{name}.'/'.$post_result->{objectID});
    $algolia->wait_task($json_data->{items}[0]->{name},$delete_result->{taskID});
    $get_result = $algolia->api_query('GET','/1/indexes/'.$json_data->{items}[0]->{name}.'/'.$post_result->{objectID});
    ok($get_result eq '404');
  }else
  {
    is(1,0,"taskID not received after POST indexes");
  }
}else
{
  diag("At least one index is needed to run all of these tests!");
}
done_testing();
