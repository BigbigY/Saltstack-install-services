include:
  - pkg.pkg-init

tengine-install:
  file.managed:
    - name: /usr/local/src/tengine-2.2.0.tar.gz
    - source: salt://tengine/files/tengine-2.2.0.tar.gz
    - user: root
    - group: root
    - mode: 755
  cmd.run:
    - name: cd /usr/local/src/ && tar xf tengine-2.2.0.tar.gz && cd tengine-2.2.0 &&  ./configure --prefix=/usr/local/tengine && make && make install
    - unless: test -d /usr/local/tengine
    - require:
      - pkg: pkg-init
      - file: tengine-install

tengine-conf:
  file.managed:
    - name: /usr/local/tengine/conf/nginx.conf
    - source: salt://tengine/files/nginx.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
tengine-init:
  file.managed:
    - name: /etc/init.d/tengine
    - source: salt://tengine/files/tengine.init
    - user: root
    - group: root
    - mode: 755
    - require:
      - cmd: tengine-install
  cmd.run:
    - name: chkconfig --add tengine
    - unless: chkconfig --list |grep tengine
    - require:
      - file: tengine-init
tengine-service:
  cmd.run:
    - name: systemctl reload tengine.service
    - require:
      - cmd: tengine-init
