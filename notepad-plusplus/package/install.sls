# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as notepad_plusplus with context %}
{%- if salt.grains.get('cpuarch') == "AMD64" %}
  {%- set temp_exe = 'C:/Windows/Temp/npp.Installer.x64.exe' %}
{%- else %}
  {%- set temp_exe = 'C:/Windows/Temp/npp.Installer.exe' %}
{%- endif %}


Download NotePad++:
  file.managed:
    - name: '{{ temp_exe }}'
    - source: '{{ notepad_plusplus.pkg.installer_uri }}'
    - skip_verify: True
    - makedirs: True

## notepad-plusplus-package-install-pkg-installed:
##   pkg.installed:
##     - name: {{ notepad__plusplus.pkg.name }}
