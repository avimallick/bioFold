#!/usr/bin/env python3
import os, sys, subprocess, glob, csv, hashlib

MERIZO = "/opt/merizo/Merizo/predict.py"

def list_pdbs(in_dir):
  return sorted(glob.glob(os.path.join(in_dir, "*.pdb")))

def select_shard(files, shards, rank):
  if shards <= 1: return files
  out = []
  for f in files:
    h = int(hashlib.md5(os.path.basename(f).encode()).hexdigest(), 16)
    if h % shards == rank:
      out.append(f)
  return out

def run_merizo(pdb_path, out_dir):
  file_id = os.path.splitext(os.path.basename(pdb_path))[0]
  run_dir = os.path.join(out_dir, file_id)
  os.makedirs(run_dir, exist_ok=True)
  cmd = ["/opt/merizo/.venv/bin/python", MERIZO, "-i", pdb_path, "-d", "cpu",
         "--save_domains", "--save_pdf", "--save_pdb", "--output_headers"]
  print(f"[Merizo] {os.path.basename(pdb_path)}")
  subprocess.run(cmd, cwd=run_dir, check=True)
  dom_pdbs = glob.glob(os.path.join(run_dir, "*.pdb"))
  n = len(dom_pdbs)
  with open(os.path.join(out_dir, f"{file_id}.dom_summary"), "w", newline="") as f:
    csv.writer(f).writerows([["ID","domain_count"], [file_id, n]])
  with open(os.path.join(out_dir, f"{file_id}_merizo_v2.domains"), "w") as f:
    for i in range(n):
      f.write(f"domain_{i+1}\n")
  return file_id, n

def main(in_dir, out_dir, shards=1, rank=0):
  os.makedirs(out_dir, exist_ok=True)
  files = list_pdbs(in_dir)
  chosen = select_shard(files, shards, rank)
  if not chosen:
    print(f"[Info] No files for this shard (rank {rank}/{shards})."); return
  summary = os.path.join(out_dir, "all.dom_summary.csv")
  with open(summary, "w", newline="") as fh:
    w = csv.writer(fh); w.writerow(["ID","domain_count"])
    for pdb in chosen:
      fid, n = run_merizo(pdb, out_dir); w.writerow([fid, n])
  print(f"Done shard {rank}/{shards}. Wrote {summary}")

if __name__ == "__main__":
  if len(sys.argv) < 3:
    print("Usage: run_pipeline.py <input_dir> <output_dir> [--shards N --rank R]"); sys.exit(1)
  in_dir, out_dir = sys.argv[1], sys.argv[2]; shards, rank = 1, 0
  if "--shards" in sys.argv: i = sys.argv.index("--shards"); shards = int(sys.argv[i+1])
  if "--rank" in sys.argv: i = sys.argv.index("--rank"); rank = int(sys.argv[i+1])
  main(in_dir, out_dir, shards, rank)
