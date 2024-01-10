FROM ruby:3.2.2

RUN apt-get update -qq && apt-get install -y postgresql-client
RUN mkdir /nomishiro_bancho
WORKDIR /nomishiro_bancho
COPY Gemfile /nomishiro_bancho/Gemfile
COPY Gemfile.lock /nomishiro_bancho/Gemfile.lock
RUN bundle install
COPY . /nomishiro_bancho

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
