FROM ruby:2.3.8-slim
LABEL maintainer="Pavel Tsurbeleu <krates@appsters.io>"

ENV RUBY_GC_HEAP_GROWTH_FACTOR=1.1 \
  RUBY_GC_MALLOC_LIMIT=4000100 \
  RUBY_GC_MALLOC_LIMIT_MAX=16000100 \
  RUBY_GC_MALLOC_LIMIT_GROWTH_FACTOR=1.1 \
  RUBY_GC_MALLOC_LIMIT=16000100 \
  RUBY_GC_OLDMALLOC_LIMIT_MAX=16000100 \
  LANG=C.UTF-8 \
  BUNDLER_VERSION=2.1.4 \
  BUNDLE_JOBS=16

ADD Gemfile /app/
ADD Gemfile.lock /app/

RUN apt-get update -y && apt-get install -y make gcc g++ && \
    gem install bundler --version ${BUNDLER_VERSION} && \
    gem cleanup bundler; cd app ; bundle install && \
    apt-get remove -y make gcc g++ && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
ADD . /app

CMD ["bundle", "exec", "thin", "-C", "app/config/thin.yml", "start"]
