FROM selim13/phpbb:3.1

LABEL version="3.1"

MAINTAINER Jan Bundesmann <community@knofafo.de>

RUN apk add --no-cache php5-ldap

#COPY language /phpbb/www/language
#COPY styles /phpbb/www/styles


EXPOSE 80
CMD ["start.sh"]
