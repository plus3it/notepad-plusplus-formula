# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as notepad_plusplus with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}
{%- set npp_admins = notepad_plusplus.config.npp_admins or ['Administrator'] %}
{%- set npp_dir = 'C:\\Program Files\\Notepad++' %}
# Initialize a namespace to persist variables across loops
{%- set npp = namespace(download_url='', version='') %}
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


include:
  - {{ sls_package_install }}

Add NPP Icon to Context Menu:
  reg.present:
    - name: 'HKEY_CLASSES_ROOT\*\shell\Open with Notepad++'
    - vname: Icon
    - value: 'C:\Program Files\Notepad++\notepad++.exe,0'
    - vtype: REG_SZ
    - require:
      - cmd: 'Install NotePad++'

Add NPP to Context Menu:
  reg.present:
    - name: 'HKEY_CLASSES_ROOT\*\shell\Open with Notepad++\command'
    - value: '"C:\Program Files\Notepad++\notepad++.exe" "%1"'
    - vtype: REG_SZ
    - require:
      - cmd: 'Install NotePad++'

Auto-updater disablement notice:
  test.show_notification:
    - text: |-
        ---------------------------------------------
        Auto-update disabled to prevent users from
        being nagged to do something outside their
        ability to effect. Administrators can still
        login and force an update, if necessary
        (typically, system will be re-deployed rather
        than updated)
        ---------------------------------------------
    - require:
      - cmd: 'Install NotePad++'

{% for admin in npp_admins %}
{% set admin_appdata = 'C:\\Users\\' ~ admin ~ '\\AppData\\Roaming\\Notepad++' %}
Create NPP Admin Config File for {{ admin }}:
  file.managed:
    - name: '{{ admin_appdata }}\config.xml'
    - contents: |
        <NotepadPlus>
            <GUIConfig name="noUpdate" yesNo="no" />
        </NotepadPlus>
    - require:
      - file: 'Ensure NPP Admin Config Dir for {{ admin }} exists'

Ensure NPP Admin Config Dir for {{ admin }} exists:
  file.directory:
    - name: '{{ admin_appdata }}'
    - makedirs: True
    - onlyif:
      - shell: powershell
      - cmd: |
          if (Get-LocalUser -Name "{{ admin }}" -ErrorAction SilentlyContinue) {
            exit 0
          } else {
            exit 1
          }
{% endfor %}

Manage Notepad++ Updater Config:
  file.managed:
    - context:
        npp_version: {{ notepad_plusplus.version }}
    - makedirs: True
    - name: 'C:\Program Files\Notepad++\updater\gup.xml'
    - require:
      - test: 'Auto-updater disablement notice'
    - source: salt://{{ tplroot }}/files/gup.xml
    - template: jinja

NPP User Template (No nagging for updates):
  file.managed:
    - name: {{ npp_dir }}\config.model.xml
    - contents: |
        <NotepadPlus>
            <GUIConfig name="noUpdate" yesNo="yes" />
        </NotepadPlus>
    - require:
      - cmd: 'Install NotePad++'

Replace System Notepad with NPP:
  reg.present:
    - name: 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe'
    - vname: Debugger
    - value: '"C:\Program Files\Notepad++\notepad++.exe" -systemedit'
    - vtype: REG_SZ
    - require:
      - cmd: 'Install NotePad++'

Set NPP App Path:
  reg.present:
    - name: 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\notepad++.exe'
    - value: 'C:\Program Files\Notepad++\notepad++.exe'
    - vtype: REG_SZ
    - require:
      - cmd: 'Install NotePad++'

Set NPP App Path Default:
  reg.present:
    - name: 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\notepad++.exe'
    - vname: Path
    - value: 'C:\Program Files\Notepad++'
    - vtype: REG_SZ
    - require:
      - cmd: 'Install NotePad++'
