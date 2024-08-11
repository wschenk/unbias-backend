ARG RUBY_VERSION=3.3.4
FROM ruby:$RUBY_VERSION-slim as base

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl sqlite3

RUN apt-get install -y python3 python3-pip python3.11-venv

RUN gem update --system --no-document && \
    bundle config set --local without development

    # Rack app lives here
WORKDIR /app

ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY requirements.txt .
RUN /opt/venv/bin/pip install -r requirements.txt

 # Install application gems
COPY Gemfile* .
RUN bundle install --without development

RUN useradd ruby --home /app --shell /bin/bash
RUN chown -R ruby:ruby /app
USER ruby:ruby
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ENV APP_ENV=production

# Copy application code
COPY --chown=ruby:ruby . .

# Start the server
EXPOSE 3000
  CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "3000"]
