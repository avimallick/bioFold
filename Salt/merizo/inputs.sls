/mnt/simulation_data/merizo_run:
  file.directory:
    - makedirs: True
    - mode: 775
    - user: ubuntu
    - group: ubuntu

/mnt/simulation_data/merizo_run/input_pdbs:
  file.recurse:
    - source: salt://merizo/input_pdbs
    - user: ubuntu
    - group: ubuntu
    - dir_mode: 775
    - file_mode: 664
    - require:
      - file: /mnt/simulation_data/merizo_run
