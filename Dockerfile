# ベースイメージ
FROM ruby:3.2.2-slim

# 必要なパッケージをインストール
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    build-essential libpq-dev postgresql-client && \
    which pg_config && \
    ls /usr/include/postgresql && \
    ls /usr/lib

# PG_CONFIG のパスを環境変数に設定
ENV PG_CONFIG=/usr/bin/pg_config
# オプション: コンパイル時にインクルードパスを指定
ENV PG_CPPFLAGS="-I/usr/include/postgresql"

# アプリケーションの作業ディレクトリ
WORKDIR /app

# GemfileとGemfile.lockをコピー
COPY Gemfile Gemfile.lock /app/

# Bundlerをインストール
RUN gem install bundler -v 2.2.3
# Bundler のグローバル設定として pg 用ビルドオプションを登録
RUN bundle config --global build.pg "--with-pg-config=${PG_CONFIG} --with-pg-include=/usr/include/postgresql --with-pg-lib=/usr/lib/x86_64-linux-gnu"


# Gemfileの依存関係をインストール
RUN bundle install

# アプリケーションコードをコピー
COPY . /app

# ポート8080をExpose
EXPOSE 8080

# アプリケーションを起動
CMD ["bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0", "-p", "8080"]

