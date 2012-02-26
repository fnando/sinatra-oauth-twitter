# -*- encoding: utf-8 -*-
require "bundler"
Bundler.setup(:default)
Bundler.require

enable :sessions
set :session_secret, "Some random and long sequence"

TWITTER_CONSUMER_KEY = "Your Twitter consumer key"
TWITTER_CONSUMER_SECRET = "Your Twitter consumer secret"
MESSAGE = "Some message"

use OmniAuth::Builder do
  provider :twitter, TWITTER_CONSUMER_KEY, TWITTER_CONSUMER_SECRET
end

Twitter.configure do |config|
  config.consumer_key = TWITTER_CONSUMER_KEY
  config.consumer_secret = TWITTER_CONSUMER_SECRET
end

get "/" do
  erb :index
end

get "/auth/twitter/callback" do
  auth = request.env["omniauth.auth"]

  Twitter.configure do |config|
    config.oauth_token = auth.credentials.token
    config.oauth_token_secret = auth.credentials.secret
  end

  begin
    Twitter.update(MESSAGE)
    redirect "/done"
  rescue Exception => error
    $stderr << "#{error.class} => #{error.message}\n"
    $stderr << error.backtrace.join("\n") << "\n"
    redirect "/fail"
  end
end

get "/auth/failure" do
  redirect "/fail"
end

get "/done" do
  erb :done
end

get "/fail" do
  erb :fail
end
