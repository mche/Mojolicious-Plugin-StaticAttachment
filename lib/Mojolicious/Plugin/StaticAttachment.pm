package Mojolicious::Plugin::StaticAttachment;
use Mojo::Base 'Mojolicious::Plugin';
use File::Basename;
use Mojo::Util qw'quote url_unescape';
#~ use Encode qw( encode );

has [qw'app'];
has paths => sub { {}; };

sub register {
  my ($self, $app, $args) = @_;
  $self->app($app)->parse_paths(delete $args->{paths});
  
  #~ warn $app->dumper($self->paths);
  
  $app->hook(after_static => sub {
    my $c = shift;
    my $path = url_unescape $c->req->url->path;
    utf8::decode($path)
      unless utf8::is_utf8($path);
    #~ warn url_unescape $path;
    return
      unless my $conf = $self->paths->{$path};
    
    #~ warn $path, %$conf;
    
    my $headers = $c->res->content->headers;
    #~ $headers->add( 'Content-Type' => $content_type . ';name=' . $filename );
    my $content_type = $conf->{content_type} || $headers->content_type || 'application/x-download';
    #~ warn $conf->{filename};
    $headers->content_type($content_type . ';name=' . $conf->{filename});
    #~ $headers->add( 'Content-Disposition'=>'attachment;filename=' . $filename );
    $headers->content_disposition('attachment;filename=' . $conf->{filename});
    #~ $c->rendered;
  });
  
  return $self;
  
}

sub parse_paths {
  my $self = shift;
  my $args = ref $_[0] ? shift : \@_;
  my $paths = $self->paths;
  while (my ($path, $conf) = splice(@$args,0,2)) {
    my($filename, $dirs, $format) = fileparse($path);
    #~ utf8::decode($filename);# if !utf8::is_utf8($filename);
    #~ utf8::decode($path) if !utf8::is_utf8($path);
    #~ $filename = quote $filename; # quote the filename, per RFC 5987
    #~ $filename = decode $filename;
      #~ unless utf8::is_utf8($filename);
    my $content_type = $self->app->types->type( $format )
      if $format;
    #~ $content_type ||= 'application/x-download';
    
    unless (ref $conf) {
      unshift @$args, $conf
        if $conf;
      $conf = {};
    }
    
    $conf->{filename} ||= $filename;
    $conf->{filename} = quote $conf->{filename};
    utf8::encode($conf->{filename})
      if utf8::is_utf8($conf->{filename});
    
    #~ warn $conf->{filename};
    $conf->{content_type} ||= $content_type
      if $content_type;
    $paths->{$path} = $conf;
  }
  return $self;
  
}

our $VERSION=0.001; # End of Mojolicious::Plugin::StaticAttachment

=pod

=encoding utf8

Доброго всем

=head1 Mojolicious::Plugin::StaticAttachment

¡ ¡ ¡ ALL GLORY TO GLORIA ! ! !

=head1 NAME

Mojolicious::Plugin::StaticAttachment - Add 'Content-Disposition' header for specified statics.

=head1 DESCRIPTION

Mojolicious plugin.

=head1 SYNOPSIS

  $app->plugin('StaticAttachment' => paths => ['/foo.txt', 'bar.portable.doc.format'=>{content_type=>'application/pdf', filename=>"файлик.pdf"}])

=head1 VERSION

Version 0.001

=cut