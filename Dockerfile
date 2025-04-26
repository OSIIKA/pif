# ベースイメージ
FROM ruby:3.2.2-slim

# 必要なパッケージをインストール
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    build-essential libpq-dev postgresql-client && \
    which pg_config && \
    ls /usr/include/postgresql && \
    ls /usr/lib

# アプリケーションの作業ディレクトリ
WORKDIR /app

# GemfileとGemfile.lockをコピー
COPY Gemfile Gemfile.lock /app/

# Bundlerをインストール
RUN gem install bundler -v 2.2.3
RUN gem install pg -- \
    --with-pg-config=/usr/bin/pg_config \
    --with-pg-include=/usr/include/postgresql \
    --with-pg-lib=/usr/lib


# Gemfileの依存関係をインストール
RUN bundle install

# アプリケーションコードをコピー
COPY . /app

# ポート8080をExpose
EXPOSE 8080

# アプリケーションを起動
CMD ["bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0", "-p", "8080"]

