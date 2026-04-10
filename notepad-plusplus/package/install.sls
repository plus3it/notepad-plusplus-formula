# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as notepad_plusplus with context %}
{%- if not notepad_plusplus.pkg.installer_uri or notepad_plusplus.pkg.installer_uri == '' -%}
    # NO URI provided in defaults, falling back to GitHub API
    {%- set github_api = "https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest" -%}
    {%- set metadata = salt['http.query'](github_api, decode=true, decode_type='json')['dict'] -%}

    {%- for asset in metadata.get('assets', []) -%}
        {%- if "Installer.x64.exe" in asset.name -%}
            {%- set download_url = asset.browser_download_url -%}
        {%- endif -%}
    {%- endfor -%}
    {%- set version = metadata.tag_name | replace('v', '') -%}
{%- else -%}
    # URI was provided in parameters, use it and the provided version
    {%- set download_url = notepad_plusplus.pkg.installer_uri -%}
    {%- set version = notepad_plusplus.pkg.version -%}
{%- endif -%}
{%- if salt.grains.get('cpuarch') == "AMD64" %}
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
    - source: '{{ download_url}}'
    - skip_verify: True
    - makedirs: True
    - require:
      - test: 'Pre-flight Message'

Install NotePad++:
  cmd.run:
    - name: |
        Start-Process "{{ temp_exe }}" -ArgumentList '/S' -Wait
        Start-Sleep -Seconds 5
    - require:
      - file: 'Download NotePad++'
    - shell: powershell
    - success_retcodes: [
        0,
        3010
      ]
    - unless: |-
        $nppPath = "C:\Program Files\Notepad++\notepad++.exe"

        if ((Test-Path $nppPath) -and ((Get-Item $nppPath).VersionInfo.FileVersion -eq "{{ version }}")) {
          Write-Host 'Already at desired version' -ForegroundColor Green
          exit 0
        } else {
          Write-Host 'Not at desired version (or not installed)' -ForegroundColor Yellow
          exit 1
        }

Pre-flight Message:
  test.show_notification:
    - text: |-
        ---------------------------------------------
        Will attempt to download Notepdd++ version
        {{ version }} from {{ download_url }}
        ---------------------------------------------
