# -*- coding: utf-8 -*-
# vim: ft=sls

{%- if grains.os_family == "Windows" %}
include:
  - .package
  - .config
{%- else %}
Invalid Platform
  test.show_notification:
    - text: |
        ----------------------------------------
        The notepad++ application is not
        published for non-Windows platform.
        Skipping all further actions.
        ----------------------------------------
{%- endif %}
