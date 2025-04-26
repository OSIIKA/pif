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
# ここで Bundler 用の環境変数も設定する
ENV BUNDLE_BUILD__PG="--with-pg-config=$PG_CONFIG --with-pg-include=/usr/include/postgresql --with-pg-lib=/usr/lib/x86_64-linux-gnu"

# アプリケーションの作業ディレクトリ
WORKDIR /app

# GemfileとGemfile.lockをコピー
COPY Gemfile Gemfile.lock /app/

# Bundlerをインストール
RUN gem install bundler -v 2.2.3
# （※ bundle config のグローバル設定も有効ですが、環境変数がより確実に反映される場合もあります）
RUN bundle config --global build.pg "$BUNDLE_BUILD__PG"


# Gemfileの依存関係をインストール
RUN bundle install

# アプリケーションコードをコピー
COPY . /app

# ポート8080をExpose
EXPOSE 8080

# アプリケーションを起動
CMD ["bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0", "-p", "8080"]

