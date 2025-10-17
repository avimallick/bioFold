# Merge all per-worker CSVs (already pushed to master's cache) into one file.
merge-merizo-csvs:
  cmd.run:
    - name: |
        set -euo pipefail
        DEST=/mnt/simulation_data/merizo_run/outputs/all.dom_summary.csv
        CACHE=/var/cache/salt/master/minions
        REL=mnt/simulation_data/merizo_run/outputs/all.dom_summary.csv
        mkdir -p /mnt/simulation_data/merizo_run/outputs

        # Pick header from first available CSV
        first=$(ls -1 "$CACHE"/*/files/$REL 2>/dev/null | head -n1 || true)
        if [ -z "${first}" ]; then
          echo "No CSVs found in cache; nothing to merge."
          exit 0
        fi

        head -n1 "$first" > "$DEST"
        for f in "$CACHE"/*/files/$REL; do
          [ -s "$f" ] || continue
          tail -n +2 "$f" >> "$DEST"
        done
        echo "Wrote $DEST"

