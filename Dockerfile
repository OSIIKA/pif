# ベースイメージ
FROM ruby:3.2.2-slim

# 必要なパッケージをインストール
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    build-essential libpq-dev postgresql-client

# アプリケーションの作業ディレクトリ
WORKDIR /app

# GemfileとGemfile.lockをコピー
COPY Gemfile Gemfile.lock /app/

# Bundlerをインストール
RUN gem install bundler -v 2.2.3

# Gemfileの依存関係をインストール
RUN bundle install

# アプリケーションコードをコピー
COPY . /app

# ポート8080をExpose
EXPOSE 8080

# アプリケーションを起動
CMD ["bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0", "-p", "8080"]

