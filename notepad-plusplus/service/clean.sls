# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as notepad__plusplus with context %}

notepad-plusplus-service-clean-service-dead:
  service.dead:
    - name: {{ notepad__plusplus.service.name }}
    - enable: False
