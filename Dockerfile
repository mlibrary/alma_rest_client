FROM ruby:2.7.2

LABEL maintainer="nique.rio@gmail.com"

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  apt-transport-https

#RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

RUN apt-get update -yqq && apt-get install -yqq --no-install-recommends \
  vim 
#  nodejs \
#  imagemagick

RUN gem install bundler:2.1.4

COPY  Gemfile* /app/
COPY alma_rest_client.gemspec /app/
COPY lib/alma_rest_client/version.rb /app/lib/alma_rest_client/version.rb

ENV BUNDLE_PATH /gems

WORKDIR /app
RUN bundle install

COPY  . /app
