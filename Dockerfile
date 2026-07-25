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

RUN gem install rails

CMD ["bash"]