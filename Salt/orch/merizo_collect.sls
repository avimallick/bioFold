# 1) Enable file_recv on the master
enable-file-recv:
  salt.state:
    - tgt: 'salt-master'
    - sls:
      - merizo.enable_file_recv

# 2) Ask workers to push their CSVs to the master cache
push-worker-csvs:
  salt.function:
    - name: cp.push
    - tgt: 'worker-*'
    - arg:
      - /mnt/simulation_data/merizo_run/outputs/all.dom_summary.csv
    - require:
      - salt: enable-file-recv

# 3) Merge them into a single CSV on the master
merge-csvs-on-master:
  salt.state:
    - tgt: 'salt-master'
    - sls:
      - merizo.merge_csv
    - require:
      - salt: push-worker-csvs

# 4) (Optional) Turn file_recv back off
# disable-file-recv:
#   salt.state:
#     - tgt: 'salt-master'
#     - sls:
#       - merizo.disable_file_recv
#     - require:
#       - salt: merge-csvs-on-master

