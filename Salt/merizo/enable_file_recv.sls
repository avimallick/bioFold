# Ensure the master accepts pushed files (needed for cp.push)
set-file-recv-true:
  file.replace:
    - name: /etc/salt/master
    - pattern: '^\s*#?\s*file_recv:.*'
    - repl: 'file_recv: True'
    - append_if_not_found: True

restart-salt-master:
  service.running:
    - name: salt-master
    - enable: True
    - watch:
      - file: set-file-recv-true

