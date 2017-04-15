use Mojo::Base -strict;

use Mojolicious::Lite;
use lib 'lib';

plugin 'StaticAttachment'=>paths=>['/sample00.txt', '/sample.txt'=>{filename=>"образец.txt"}, '/образец.txt'=>{content_type=>"app/foo"},];

app->start;