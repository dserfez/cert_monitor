FROM alpine:3.7

RUN apk --update --no-cache add ruby ruby-json less \
    && gem install --no-ri --no-rdoc httpclient pry

ADD certmon.rb /opt/certificate_monitor.rb

ENTRYPOINT ["ruby", "/opt/certificate_monitor.rb"]
