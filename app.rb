require 'sinatra'
require 'oauth2'
require 'json'

enable :sessions
enable :inline_templates

SCOPES = [
    'https://www.googleapis.com/auth/userinfo.email',
    'https://www.googleapis.com/auth/userinfo.profile'
].join(' ')

raise "GOOGLE_CLIENT must be set" unless ENV['GOOGLE_CLIENT']
raise "GOOGLE_SECRET must be set" unless ENV['GOOGLE_SECRET']

def client
  @client ||= OAuth2::Client.new(ENV['GOOGLE_CLIENT'], ENV['GOOGLE_SECRET'], {
      site: 'https://accounts.google.com',
      authorize_url: '/o/oauth2/auth',
      token_url: '/o/oauth2/token'
  })
end

def redirect_uri
  URI.parse(request.url).tap do |uri|
    uri.path = '/oauth2/callback'
    uri.query = nil
  end.to_s
end

get '/' do
  puts session[:access_token]
  erb :index
end

get '/login' do
  redirect client.auth_code.authorize_url(redirect_uri: redirect_uri, scope: SCOPES, access_type: 'offline')
end

get '/oauth2/callback' do
  access_token = client.auth_code.get_token(params[:code], redirect_uri: redirect_uri)
  session[:access_token] = access_token.token
  email = access_token.get('https://www.googleapis.com/userinfo/email?alt=json')
  profile = access_token.get('https://www.googleapis.com/oauth2/v1/userinfo?alt=json')
  erb :welcome, locals: { name: email.parsed, details: profile.parsed, message: 'Congratulations!' }
end

__END__
@@ layout
<!DOCTYPE html>
<html>
<body><%= yield %></body>
</html>

@@ index
<a href="/login">Login</a>

@@ welcome
Welcome <%= name %>!<br>
<%= details.inspect %>
<hr>
<%= message %>
