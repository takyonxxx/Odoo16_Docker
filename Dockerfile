FROM ubuntu:20.04
USER root
MAINTAINER Türkay Biliyor <https://turkay.biliyor.org.tr/>
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get clean
RUN apt-get update
RUN apt-get upgrade -y
RUN adduser -system -home=/opt/odoo -group odoo

RUN apt-get install python3 python3-dev python3-pip build-essential  \
    libffi-dev xvfb wkhtmltopdf python3-boto3 libxml2-dev libxslt1-dev  \
    libsasl2-dev libldap2-dev libssl-dev libjpeg-dev zlib1g-dev libpq-dev git -y

RUN apt-get install python3-suds python3-cryptography -y
RUN apt-get install nodejs node-less npm -y

RUN npm install -g less@3.13.1 -y
RUN npm install -g less-plugin-clean-css

RUN mkdir --parents /opt/odoo
RUN useradd --create-home --password odoo odoo || true
RUN chown --recursive odoo /opt/odoo/
RUN git clone https://github.com/odoo/odoo.git --branch 16.0 --depth 1 /opt/odoo/server
#COPY ./odoo /opt/odoo/server

VOLUME ["/var/lib/odoo"]
EXPOSE 8069
# Set the default config file
ENV ODOO_RC /opt/odoo/odoo.conf

COPY ./requirements.txt /opt/odoo/server/
RUN chown odoo:odoo -R /opt/odoo/
COPY ./odoo.conf /opt/odoo/
RUN chown odoo:odoo /opt/odoo/odoo.conf
COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

# RUN cd /opt/odoo/server/addons && mv l10n_tr/ l10n_tr_orj/

WORKDIR /opt/odoo/server/

RUN pip3 install --upgrade pip setuptools wheel
RUN pip3 install scikit-build
RUN pip install pyinotify

RUN pip3 install "setuptools==58.0.0"
RUN pip3 install --upgrade -r requirements.txt

CMD ["su", "-", "odoo", "/bin/bash"]
RUN python3 setup.py install

USER odoo
CMD ["odoo", "--addons-path=addons", "-c", "/opt/odoo/odoo.conf", "--db_host=odoo_db", "--db_user=admin", "--db_password=admin"]

#CMD ["odoo", "--addons-path=addons,/opt/odoo/extra_addons", "-c", "/opt/odoo/odoo.conf", "--db_host=odoo_db", "--db_user=admin", "--db_password=admin"]

