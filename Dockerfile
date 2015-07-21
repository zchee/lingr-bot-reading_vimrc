FROM ruby:latest
MAINTAINER zchee <zcheeee@gmail.com>

WORKDIR /usr/src/app

RUN bundle config --global jobs 8
COPY Gemfile /usr/src/app/
RUN bundle install

COPY . /usr/src/app
RUN mkdir /usr/src/app/log
RUN touch /usr/src/app/log/development.log

EXPOSE 80
CMD ["/usr/local/bundle/bin/foreman", "start", "-d","/usr/src/app", "-p", "80"]
