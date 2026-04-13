# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as notepad_plusplus with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
{%- set npp_admins = notepad_plusplus.config.npp_admins or ['Administrator'] %}
{%- set npp_dir = 'C:\\Program Files\\Notepad++' %}

include:
  - {{ sls_package_install }}

NPP User Template (No nagging for updates):
  file.managed:
    - name: {{ npp_dir }}\config.model.xml
    - contents: |
        <NotepadPlus>
            <GUIConfig name="noUpdate" yesNo="yes" />
        </NotepadPlus>

{% for admin in npp_admins %}
{% set admin_appdata = 'C:\\Users\\' ~ admin ~ '\\AppData\\Roaming\\Notepad++' %}
Ensure NPP Admin Config Dir for {{ admin }} exists:
  file.directory:
    - name: '{{ admin_appdata }}'
    - makedirs: True
    # Gracefully skip if the account was renamed or doesn't exist
    - onlyif: 'if ( Test-Path "C:\Users\{{ admin }}" ) { exit 0 } else { exit 1 }'

Create NPP Admin Config File for {{ admin }}:
  file.managed:
    - name: '{{ admin_appdata }}\config.xml'
    - contents: |
        <NotepadPlus>
            <GUIConfig name="noUpdate" yesNo="no" />
        </NotepadPlus>
    - require:
      - file: 'Ensure NPP Admin Config Dir for {{ admin }} exists'
    # Double-guard to ensure we don't attempt to write to a non-existent path
    - onlyif: 'if ( Test-Path "C:\Users\{{ admin }}" ) { exit 0 } else { exit 1 }'
{% endfor %}
