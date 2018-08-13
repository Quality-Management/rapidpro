FROM ilha/rapidpro-base:base

RUN apt-get install varnish wget -y

RUN wget http://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem \
    -O /usr/local/share/ca-certificates/rds.crt
RUN update-ca-certificates

COPY varnish.default.vcl /etc/varnish/default.vcl

COPY pip-freeze.txt .

RUN pip install -r pip-freeze.txt

COPY package.json .

RUN npm install

COPY . .

COPY settings.py.pre temba/settings.py

RUN python manage.py collectstatic --noinput
RUN python manage.py compress --extension=.haml,.html

EXPOSE 8000
EXPOSE 8080

ENTRYPOINT ["./entrypoint.sh"]

CMD ["supervisor"]