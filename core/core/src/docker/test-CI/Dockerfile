FROM epiphanyregistry.azurecr.io/epiphany-deploy:1640-release022
# to be removed
COPY core/core/src/docker/test-CI/run.sh /epiphany/core/core/src/docker/test-CI/run.sh 
# to be removed
COPY core/core/src/docker/test-CI/prepare_sp.sh /epiphany/core/core/src/docker/test-CI/prepare_sp.sh 

RUN mkdir /tmp/keys

RUN ssh-keygen -q -t rsa -N '' -f /tmp/keys/id_rsa

RUN apk add --no-cache ruby ruby-rdoc ruby-irb ruby-rake

RUN gem install bundler

RUN bundle config --global silence_root_warning 1

WORKDIR /epiphany/core/core/test/serverspec

RUN bundle install

WORKDIR /epiphany

RUN chmod chmod a+x /epiphany/core/core/src/docker/test-CI/run.sh

CMD ["/epiphany/core/core/src/docker/test-CI/run.sh"]
