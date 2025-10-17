/opt/merizo:
  file.directory:
    - makedirs: True
    - mode: 755

merizo-repo:
  git.latest:
    - name: https://github.com/psipred/Merizo.git
    - target: /opt/merizo/Merizo
    - rev: main
    - force_reset: True
    - require:
      - file: /opt/merizo

/opt/merizo/.venv:
  cmd.run:
    - name: python3 -m venv /opt/merizo/.venv
    - creates: /opt/merizo/.venv
    - require:
      - git: merizo-repo

pip-base:
  cmd.run:
    - name: |
        bash -lc '
          source /opt/merizo/.venv/bin/activate
          pip install --upgrade pip wheel
          pip install -r /opt/merizo/Merizo/requirements.txt
          pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
        '
    - unless: test -f /opt/merizo/.venv/.done.pip
    - require:
      - cmd: /opt/merizo/.venv

/opt/merizo/.venv/.done.pip:
  file.touch:
    - require:
      - cmd: pip-base
