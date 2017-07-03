{% from "jenkins/map.jinja" import jenkins with context %}

jenkins_install:
  {% if grains['os_family'] in ['RedHat', 'Debian'] %}
    {% set repo_suffix = '' %}
    {% if jenkins.stable %}
      {% set repo_suffix = '-stable' %}
    {% endif %}
  pkgrepo.managed:
    - humanname: Jenkins upstream package repository
    {% if grains['os_family'] == 'RedHat' %}
    - baseurl: http://pkg.jenkins-ci.org/redhat{{ repo_suffix }}
    - gpgkey: http://pkg.jenkins-ci.org/redhat{{ repo_suffix }}/jenkins-ci.org.key
    {% elif grains['os_family'] == 'Debian' %}
    - file: {{jenkins.deb_apt_source}}
    - name: deb http://pkg.jenkins-ci.org/debian{{ repo_suffix }} binary/
    - key_url: http://pkg.jenkins-ci.org/debian{{ repo_suffix }}/jenkins-ci.org.key
    {% endif %}
    - require_in:
      - pkg: jenkins
  {% endif %}
  pkg.installed:
    - pkgs: {{ jenkins.pkgs|json }}
  service.running:
    - name: jenkins
    - enable: True
    - watch:
      - file: jenkins_config

{% if grains['os_family'] in ['RedHat', 'Debian'] %}
jenkins_config:
  file.managed:
    {% if grains['os_family'] == 'RedHat' %}
    - name: /etc/sysconfig/jenkins
    - source: salt://jenkins/files/RedHat/jenkins.conf
    {% elif grains['os_family'] == 'Debian' %}
    - name: /etc/default/jenkins
    - source: salt://jenkins/files/Debian/jenkins.conf
    {% endif %}
    - template: jinja
    - user: root
    - group: root
    - mode: 400
{% endif %}
