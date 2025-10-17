# Include everything required for execution
include:
  - merizo.install
  - merizo.code
  - merizo.inputs

# Fetch shard configuration and rank from pillar
{% set shards = pillar.get('merizo_shards', 4) %}
{% set rank_map = pillar.get('merizo_rank_map', {}) %}
{% set myid = grains.get('id') %}
{% set rank = rank_map.get(myid, 0) %}

/mnt/simulation_data/merizo_run/outputs:
  file.directory:
    - makedirs: True
    - mode: 775
    - user: ubuntu
    - group: ubuntu

run-merizo-shard:
  cmd.run:
    - name: |
        bash -lc '
          source /opt/merizo/.venv/bin/activate
          /opt/merizo/.venv/bin/python /opt/merizo/run_pipeline.py \
            /mnt/simulation_data/merizo_run/input_pdbs \
            /mnt/simulation_data/merizo_run/outputs \
            --shards {{ shards }} --rank {{ rank }}
        '
    - env:
        PYTHONUNBUFFERED: '1'
    - timeout: 86400
    - require:
      - file: /mnt/simulation_data/merizo_run/outputs
      - file: /opt/merizo/run_pipeline.py
      - cmd: /opt/merizo/.venv
