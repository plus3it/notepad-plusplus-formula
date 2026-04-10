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

Delete EXE-installer:
  file.absent:
    - name: '{{ temp_exe }}'
    - require:
      - cmd: 'Install NotePad++'

Download NotePad++:
  file.managed:
    - name: '{{ temp_exe }}'
    - source: '{{ notepad_plusplus.pkg.installer_uri }}'
    - skip_verify: True
    - makedirs: True

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

        if ((Test-Path $nppPath) -and ((Get-Item $nppPath).VersionInfo.FileVersion -eq "{{ notepad_plusplus.pkg.version }}")) {
          Write-Host 'Already at desired version' -ForegroundColor Green
          exit 0
        } else {
          Write-Host 'Not at desired version (or not installed)' -ForegroundColor Yellow
          exit 1
        }
