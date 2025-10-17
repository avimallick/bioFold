# Turn file_recv back off (optional hardening)
set-file-recv-false:
  file.replace:
    - name: /etc/salt/master
    - pattern: '^\s*#?\s*file_recv:.*'
    - repl: 'file_recv: False'
    - append_if_not_found: True

restart-salt-master:
  service.running:
    - name: salt-master
    - enable: True
    - watch:
      - file: set-file-recv-false

