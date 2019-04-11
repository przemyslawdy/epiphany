FROM epiphanyregistry.azurecr.io/epiphany-deploy:latest

# to be removed
COPY core/core/src /epiphany/core/core/src 
COPY core/core/test/serverspec /epiphany/core/core/test/serverspec 
#
RUN mkdir /tmp/keys

RUN ssh-keygen -q -t rsa -N '' -f /tmp/keys/id_rsa

RUN apk add --no-cache ruby ruby-rdoc ruby-irb ruby-rake

RUN gem install bundler

RUN bundle config --global silence_root_warning 1

WORKDIR /epiphany/core/core/test/serverspec

RUN bundle install

WORKDIR /epiphany

RUN chmod a+x /epiphany/core/core/src/docker/test-CI/run.sh

CMD ["/epiphany/core/core/src/docker/test-CI/run.sh"]
