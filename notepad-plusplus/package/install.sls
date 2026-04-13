# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/' )[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as notepad_plusplus with context %}
# Initialize a namespace to persist variables across loops
{%- set npp = namespace(download_url='', version='' ) %}

{%- if not notepad_plusplus.pkg.installer_uri %}
    # Fallback to GitHub API
    {%- set github_api = "https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest" %}
    {%- set metadata = salt['http.query'](github_api, decode=true, decode_type='json' )['dict'] %}

    {%- set npp.version = metadata.get('tag_name', '0.0.0' ) | replace('v', '' ) %}

    {%- for asset in metadata.get('assets', [] ) %}
        {%- if "Installer.x64.exe" in asset.name %}
            {%- set npp.download_url = asset.browser_download_url %}
        {%- endif %}
    {%- endfor %}
{%- else %}
    # Use provided parameters
    {%- set npp.download_url = notepad_plusplus.pkg.installer_uri %}
    {%- set npp.version = notepad_plusplus.pkg.version %}
{%- endif %}
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
    - source: '{{ npp.download_url}}'
    - skip_verify: True
    - makedirs: True
    - require:
      - test: 'Pre-flight Message'

Install NotePad++:
  cmd.script:
    - source: salt://{{ tplroot }}/files/npp_install.ps1
    - args: "'{{ npp.version }}' '{{ temp_exe }}'"
    - shell: powershell
    - require:
      - file: 'Download NotePad++'

Pre-flight Message:
  test.show_notification:
    - text: |-
        ---------------------------------------------
        Will attempt to download Notepdd++ version
        {{ npp.version }} from {{ npp.download_url }}
        ---------------------------------------------
