This provides a starter kit for implementing Google OAuth2 access in Sinatra.

[Create credentials on Google](https://console.developers.google.com/apis/credentials)

Add an entry into `/etc/hosts` for your domain name

Set the client and secret into the `GOOGLE_CLIENT` and `GOOGLE_SECRET` environment variables.

Before running, use:

    bundle install

Launch with:

    rackup -o 0.0.0.0 -p 9292
