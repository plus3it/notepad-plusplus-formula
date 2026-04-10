# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as notepad__plusplus with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

notepad-plusplus-config-file-file-managed:
  file.managed:
    - name: {{ notepad__plusplus.config }}
    - source: {{ files_switch(['example.tmpl'],
                              lookup='notepad-plusplus-config-file-file-managed'
                 )
              }}
    - mode: 644
    - user: root
    - group: {{ notepad__plusplus.rootgroup }}
    - makedirs: True
    - template: jinja
    - require:
      - sls: {{ sls_package_install }}
    - context:
        notepad__plusplus: {{ notepad__plusplus | json }}
