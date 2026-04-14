# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/' )[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as notepad_plusplus with context %}
{%- set npp_version = notepad_plusplus.version %}
{%- set npp_url = notepad_plusplus.download_url %}
{%- if salt.grains.get('cpuarch' ) == "AMD64" %}
  {%- set temp_exe = 'C:/Windows/Temp/npp.Installer.x64.exe' %}
{%- else %}
  {%- set temp_exe = 'C:/Windows/Temp/npp.Installer.exe' %}
{%- endif %}

Delete EXE-installer:
  file.absent:
    - name: '{{ temp_exe }}'
    - require:
      - cmd: 'Install NotePad++'

Download NotePad++:
  file.managed:
    - name: '{{ temp_exe }}'
    - source: '{{ npp_url }}'
    - skip_verify: True
    - makedirs: True
    - require:
      - test: 'Pre-flight Message'

Install NotePad++:
  cmd.script:
    - source: salt://{{ tplroot }}/files/npp_install.ps1
    - args: "'{{ npp_version }}' '{{ temp_exe }}'"
    - shell: powershell
    - require:
      - file: 'Download NotePad++'

Pre-flight Message:
  test.show_notification:
    - text: |-
        ---------------------------------------------
        Will attempt to download Notepdd++ version
        {{ npp_version }} from {{ npp_url }}
        ---------------------------------------------
