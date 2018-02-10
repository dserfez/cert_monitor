FROM alpine:3.7

RUN apk --update --no-cache add ruby ruby-json less \
    && gem install --no-ri --no-rdoc httpclient pry concurrent-ruby

ADD certmon.rb /opt/certificate_monitor.rb

RUN chmod a+rx /opt/certificate_monitor.rb

WORKDIR "/opt"

USER guest

ENTRYPOINT ["ruby", "/opt/certificate_monitor.rb"]
