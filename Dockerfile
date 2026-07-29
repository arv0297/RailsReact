FROM ruby:3.4.10-slim
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libyaml-dev \
    pkg-config \
    nodejs \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY . .

RUN gem install rails

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]