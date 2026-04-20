# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as notepad_plusplus with context %}

include:
  - {{ sls_config_clean }}

Purge Notepad++ Directory:
  file.absent:
    - name: 'C:\Program Files\Notepad++'
    - onchanges:
      - cmd: Uninstall Notepad++

Uninstall Notepad++:
  cmd.script:
    - source: salt://{{ tplroot }}/files/npp_uninstall.ps1
    - shell: powershell
    - success_retcodes: [
        0,
        100
      ]
