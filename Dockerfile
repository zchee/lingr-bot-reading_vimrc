FROM ruby:latest
MAINTAINER zchee <k@zchee.io>

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock /usr/src/app/
RUN bundle config build.nokogiri --use-system-libraries \
	&& bundle install --jobs $(nproc)

COPY . /usr/src/app
RUN mkdir /usr/src/app/log \
	&& touch /usr/src/app/log/development.log

EXPOSE 80
CMD ["/usr/local/bundle/bin/foreman", "start", "-d","/usr/src/app"]
