/opt/merizo/run_pipeline.py:
  file.managed:
    - source: salt://merizo/files/run_pipeline.py
    - mode: 755
    - require:
      - git: merizo-repo
