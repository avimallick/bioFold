# 🧬 bioFold — Distributed Protein Domain Segmentation Pipeline

**Author:** Avinash Mallick  
---

## 📖 Overview

**bioFold** is a distributed, fully automated protein domain segmentation pipeline.  
It leverages:
- **Terraform** for cloud VM provisioning  
- **SaltStack** for configuration management and orchestration  
- **Merizo** (PSI Group, UCL) for deep learning–based domain segmentation  
- **Python + PyTorch** for CPU-based inference  

The system automatically provisions infrastructure, configures worker nodes, distributes protein structure inputs (`.pdb` files), runs Merizo inference in parallel, and aggregates the final domain segmentation results across nodes.

---

## 🧱 Project Architecture

```
bioFold/
├── terraform/        # Infrastructure provisioning
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── inventory.ini
│   └── README.md
│
├── salt/             # Configuration management and orchestration
│   ├── top.sls
│   ├── merizo/
│   │   ├── common.sls
│   │   ├── install.sls
│   │   ├── code.sls
│   │   ├── inputs.sls
│   │   ├── run.sls
│   │   ├── files/
│   │   │   ├── run_pipeline.py
│   │   │   └── input_pdbs/
│   │   └── orch/
│   │       └── merizo_collect.sls
│   └── README.md
│
├── pillar/           # (optional) pillar definitions for sharding and ranks
│   └── merizo.sls
│
└── README.md         # (this file)
```

---

## ☁️ Infrastructure Details

| Role | Hostname | IP Address | CPU / Memory | Storage |
|------|-----------|-------------|---------------|----------|
| **Salt Master** | `ucab252-salt-master-61eebe190e` | `10.134.12.159` | 4 vCPUs / 8 GB RAM | 60 GB |
| **Client Node** | `ucab252-client-61eebe190e` | `10.134.12.157` | 4 vCPUs / 8 GB RAM | 60 GB |
| **Worker 1** | `ucab252-worker-01-61eebe190e` | `10.134.12.158` | 6 vCPUs / 16 GB RAM | 60 GB + 250 GB `/mnt/simulation_data` |
| **Worker 2** | `ucab252-worker-02-61eebe190e` | `10.134.12.160` | 6 vCPUs / 16 GB RAM | 60 GB + 250 GB `/mnt/simulation_data` |
| **Worker 3** | `ucab252-worker-03-61eebe190e` | `10.134.12.122` | 6 vCPUs / 16 GB RAM | 60 GB + 250 GB `/mnt/simulation_data` |
| **Worker 4** | `ucab252-worker-04-61eebe190e` | `10.134.12.156` | 6 vCPUs / 16 GB RAM | 60 GB + 250 GB `/mnt/simulation_data` |

---

## 🧩 Components

### 1. Terraform — Infrastructure as Code
Provisions 1 Salt master, 1 client node, and 4 worker nodes.

### 2. SaltStack — Configuration and Orchestration
Automates dependency installation, cloning Merizo, setting up virtual environments, copying inputs, running inference, and merging outputs.

### 3. Merizo — Protein Domain Segmentation
Deep learning model for protein structural domain identification.

---

## 🧠 Sharding Configuration

```yaml
merizo_shards: 4
merizo_rank_map:
  worker-1: 0
  worker-2: 1
  worker-3: 2
  worker-4: 3
```

---

## 🧪 Distributed Execution Example

### Command
```bash
sudo salt -E 'worker-.*' state.apply merizo.common,merizo.install,merizo.code,merizo.inputs,merizo.run
```

### Example Output
```
worker-1: Processed 2XDQ.pdb, 3QVU.pdb
worker-2: Processed 2HHB.pdb, 4AKE.pdb
worker-3: No files for this shard
worker-4: Processed 1CRN.pdb
```

### Aggregation
```bash
sudo salt-run state.orchestrate orch.merizo_collect
```

---

## 📊 Example Output (Merged CSV)

```
input,nres,nres_dom,nres_ndr,ndom,pIoU,runtime,result
1CRN.pdb,46,46,0,1,0.74156,0.48584,1-46
2HHB.pdb,141,141,0,1,1.00000,0.99310,1-141
4AKE.pdb,214,210,4,2,0.98131,1.27991,1-110_200-210,111-199
2XDQ.pdb,425,425,0,3,0.98407,3.06417,6-18_296-459,19-156,157-162_192-295
3QVU.pdb,288,288,0,1,0.64585,2.33818,8-295
```

---

## 📈 Performance Summary

| Metric | Value |
|--------|--------|
| Total Nodes | 6 (1 master, 1 client, 4 workers) |
| Total PDBs | 5 |
| Avg Runtime (per PDB) | 2–3 s |
| Total Pipeline Duration | ≈ 30 s |
| Speed-up vs Single Node | ~3.5× |

---

## 🔧 Future Work
- Shared filesystem (NFS/S3) for auto-merging results  
- Prometheus + Grafana for monitoring  
- GPU acceleration (CUDA/ROCm)  
- Dynamic load balancing via Dask or Slurm  

---

## 🧩 Key Learnings
- SaltStack provides full reproducibility for distributed scientific workloads  
- Terraform + Salt = end-to-end Infrastructure-as-Code workflow  
- Simple CPU nodes can scale effectively for bioinformatics workloads  

---

## 🧾 References

1. PSI Group — [Merizo: Protein Domain Segmentation Model](https://github.com/psipred/Merizo)  
2. Salt Project — [SaltStack Documentation](https://docs.saltproject.io)  
3. PyTorch — [Deep Learning Framework](https://pytorch.org)  
4. Mallick, A. (2025). *bioFold: Distributed Protein Structure Analysis Pipeline.*  
   [github.com/avimallick/bioFold](https://github.com/avimallick/bioFold)

---

## 🧠 Author
**Avinash Mallick**  
UCL MSc Software Systems Engineering  
[LinkedIn](https://www.linkedin.com/in/avinash-mallick) • [GitHub](https://github.com/avimallick)
