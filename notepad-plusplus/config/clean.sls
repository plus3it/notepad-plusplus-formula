# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as notepad_plusplus with context %}
{%- set npp_admins = notepad_plusplus.config.npp_admins or ['Administrator'] %}
{%- set npp_dir = 'C:\\Program Files\\Notepad++' %}

{# Map descriptive IDs to their respective Registry paths #}
{%- set npp_registry_map = {
    'NPP Application Path': 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\notepad++.exe',
    'NPP Context Menu Entry': 'HKEY_CLASSES_ROOT\\*\\shell\\Open with Notepad++',
    'NPP MuiCache Entry': 'HKEY_CLASSES_ROOT\\Local Settings\\Software\\Microsoft\\Windows\\Shell\\MuiCache',
    'NPP OpenWithList txt': 'HKEY_CLASSES_ROOT\\.txt\\OpenWithList\\notepad++.exe',
    'NPP System Notepad Replacement': 'HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Image File Execution Opt
ions\\notepad.exe'
  }
%}

{%- for desc, reg_path in npp_registry_map.items() %}
Remove {{ desc }}:
  reg.absent:
    - name: '{{ reg_path }}'
{%- endfor %}

{%- for admin in npp_admins %}
Remove NPP AppData for {{ admin }}:
  file.absent:
    - name: 'C:\Users\{{ admin }}\AppData\Roaming\Notepad++'
{%- endfor %}

Remove NPP System Config Files:
  file.absent:
    - names:
      - '{{ npp_dir }}\updater\gup.xml'
      - '{{ npp_dir }}\config.model.xml'
