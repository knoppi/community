FROM php:7.2-apache

MAINTAINER Jan Bundesmann <community@knofafo.de>

RUN apt-get update && apt-get install -y curl unzip bzip2 libpq-dev libpng-dev libjpeg-dev libldap2-dev \
        && rm -rf /var/lib/apt/lists/* \
        && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
        && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
        && docker-php-ext-install gd mysqli ldap

WORKDIR /var/www/html

ENV PHPBB_VERSION 3.2.2
ENV PHPBB_URL https://www.phpbb.com/files/release/phpBB-${PHPBB_VERSION}.tar.bz2
ENV PHPBB_SHA bab64dbd79f6f1bf2c0c306b33cea460ffe58c56ff1e81aac87ee10545291302
ENV PHPBB_FILE phpBB.tar.bz2

RUN curl -fSL ${PHPBB_URL} -o ${PHPBB_FILE} \
        && echo "${PHPBB_SHA} ${PHPBB_FILE}" | sha256sum -c - \
        && tar -xjf ${PHPBB_FILE} --strip-components=1 \
        && rm ${PHPBB_FILE} \
        && chown -R www-data:www-data .

# At a later point I will separate installation- and production-image
# RUN rm -R /var/www/html/install

# German language pack
ENV LANG_DE_PACK_URL https://www.phpbb.com/customise/db/download/152921
ENV LANG_DE_PACK_MD5 5075ab89babe1d51a3c3c69b8affcbc5
ENV LANG_DE_PACK_FILE german_casual_honorifics_3_2_2.zip
ENV LANG_DE_PACK_DIR german_casual_honorifics_3_2_2

WORKDIR /var/www/html

RUN curl -fSL ${LANG_DE_PACK_URL} -o ${LANG_DE_PACK_FILE}
RUN echo ${LANG_DE_PACK_MD5} ${LANG_DE_PACK_FILE} | md5sum -w -c -
RUN unzip ${LANG_DE_PACK_FILE}

RUN mkdir -p language && mkdir -p styles \
    && mv ${LANG_DE_PACK_DIR}/language/de language \
    && mv ${LANG_DE_PACK_DIR}/styles styles \
    && rm -R ${LANG_DE_PACK_FILE} \
    && rm -R ${LANG_DE_PACK_DIR} \
    && chown -R www-data:www-data language \
    && chown -R www-data:www-data styles

EXPOSE 80
CMD ["start.sh"]
