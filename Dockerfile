# ベースイメージを指定
FROM ruby:3.2.3-slim

# アプリケーションディレクトリを作成
WORKDIR /app

# 必要なパッケージをインストール
RUN apt-get update -qq && apt-get install --no-install-recommends -y \
  build-essential libsqlite3-dev nodejs npm

# GemfileとGemfile.lockをコピー
COPY Gemfile Gemfile.lock /app/

# Bundlerを利用して依存関係をインストール
RUN bundle install

# アプリケーションコードをコピー
COPY . /app

# Fly.ioが使用するポートをExpose
EXPOSE 8080

# アプリケーションを起動
CMD ["bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0", "-p", "8080"]
