FROM epiphanyplatform/epiphany-deploy:latest

RUN mkdir /tmp/keys

RUN ssh-keygen -q -t rsa -N '' -f /tmp/keys/id_rsa

RUN apk add --no-cache ruby ruby-rdoc ruby-irb ruby-rake

RUN gem install bundler

RUN bundle config --global silence_root_warning 1

WORKDIR /epiphany/core/core/test/serverspec

RUN bundle install

WORKDIR /epiphany

# RUN mkdir -p core/data/azure/infrastructure/epiphany-qa-template

# RUN mkdir -p core/build/azure/infrastructure/epiphany-qa-rhel

# RUN mkdir -p core/build/azure/infrastructure/epiphany-qa-ubu

# COPY core/data/azure/infrastructure/epiphany-qa-template/ core/data/azure/infrastructure/epiphany-qa-template/

# COPY core/data/azure/infrastructure/epiphany-qa-rhel/basic-data.yaml core/data/azure/infrastructure/epiphany-qa-rhel/basic-data.yaml

# COPY core/data/azure/infrastructure/epiphany-qa-ubu/basic-data.yaml core/data/azure/infrastructure/epiphany-qa-ubu/basic-data.yaml

CMD ["/epiphany/core/core/src/docker/test-CI/run.sh"]
