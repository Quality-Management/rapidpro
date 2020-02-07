FROM ilha/rapidpro-base:base

RUN apt-get install varnish wget python3.6 python3.6-dev python3.6-minimal -y

RUN curl https://bootstrap.pypa.io/get-pip.py | python3.6

RUN wget https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem \
    -O /usr/local/share/ca-certificates/rds.crt
RUN update-ca-certificates

COPY varnish.default.vcl /etc/varnish/default.vcl

COPY pip-freeze.txt .

RUN pip install -r pip-freeze.txt

COPY package.json .

RUN npm install

COPY . .

COPY settings.py.pre temba/settings.py

RUN python3.6 manage.py collectstatic --noinput
RUN python3.6 manage.py compress --extension=.haml,.html

EXPOSE 8000
EXPOSE 8080

ENTRYPOINT ["./entrypoint.sh"]

CMD ["supervisor"]
