# Data sources for image and SSH key
data "harvester_image" "img" {
  display_name = var.img_display_name
  namespace    = "harvester-public"
}

data "harvester_ssh_key" "mysshkey" {
  name      = var.keyname
  namespace = var.namespace
}

# Random ID for unique resource naming
resource "random_id" "secret" {
  byte_length = 5
}

############################
# Predictable hostnames
############################
locals {
  master_hostname = "${var.username}-salt-master-${random_id.secret.hex}"
  client_hostname = "${var.username}-client-${random_id.secret.hex}"
  worker_name     = "${var.username}-worker"
}

############################
# Cloud-init secrets
############################

# Master cloud-init
resource "harvester_cloudinit_secret" "cloud_master" {
  name      = "cloud-master-${random_id.secret.hex}"
  namespace = var.namespace

  user_data = templatefile("${path.module}/cloud-init-master.yml", {
    public_key_openssh = data.harvester_ssh_key.mysshkey.public_key,
    lecturer_key       = file("${path.module}/lecturer_key.pub")
  })
}

# Minion cloud-init (parameterised by role + master fqdn)
# We’ll reuse this for client and workers by passing different 'role'
resource "harvester_cloudinit_secret" "cloud_minion_client" {
  name      = "cloud-minion-client-${random_id.secret.hex}"
  namespace = var.namespace

  user_data = templatefile("${path.module}/cloud-init-minion.yml", {
    public_key_openssh = data.harvester_ssh_key.mysshkey.public_key,
    lecturer_key       = file("${path.module}/lecturer_key.pub"),
    master_fqdn        = local.master_hostname,
    role               = "client"
  })
}

resource "harvester_cloudinit_secret" "cloud_minion_worker" {
  name      = "cloud-minion-worker-${random_id.secret.hex}"
  namespace = var.namespace

  user_data = templatefile("${path.module}/cloud-init-minion.yml", {
    public_key_openssh = data.harvester_ssh_key.mysshkey.public_key,
    lecturer_key       = file("${path.module}/lecturer_key.pub"),
    master_fqdn        = local.master_hostname,
    role               = "worker"
  })
}

############################
# Management Node (salt-master)
############################
resource "harvester_virtualmachine" "salt_master" {
  name                 = local.master_hostname
  namespace            = var.namespace
  restart_after_update = true
  description          = "Salt master / host for COMP0235"
  cpu                  = 2
  memory               = "8Gi"
  efi                  = true
  secure_boot          = false
  run_strategy         = "RerunOnFailure"
  hostname             = local.master_hostname
  reserved_memory      = "100Mi"
  machine_type         = "q35"

  network_interface {
    name           = "nic-1"
    wait_for_lease = true
    type           = "bridge"
    network_name   = var.network_name
  }

  disk {
    name        = "rootdisk"
    type        = "disk"
    size        = "40Gi"
    bus         = "virtio"
    boot_order  = 1
    image       = data.harvester_image.img.id
    auto_delete = true
  }

  cloudinit {
    user_data_secret_name = harvester_cloudinit_secret.cloud_master.name
  }

  ssh_keys = [data.harvester_ssh_key.mysshkey.id]

  tags = {
    role        = "salt-master"
    description = "salt-master-management"
  }
}

############################
# Client (aggregator)
############################
resource "harvester_virtualmachine" "client" {
  name                 = local.client_hostname
  namespace            = var.namespace
  restart_after_update = true
  description          = "Client / results aggregator"
  cpu                  = 4
  memory               = "16Gi"
  efi                  = true
  secure_boot          = false
  run_strategy         = "RerunOnFailure"
  hostname             = local.client_hostname
  reserved_memory      = "100Mi"
  machine_type         = "q35"

  network_interface {
    name           = "nic-1"
    wait_for_lease = true
    type           = "bridge"
    network_name   = var.network_name
  }

  disk {
    name        = "rootdisk"
    type        = "disk"
    size        = "120Gi"
    bus         = "virtio"
    boot_order  = 1
    image       = data.harvester_image.img.id
    auto_delete = true
  }

  cloudinit {
    user_data_secret_name = harvester_cloudinit_secret.cloud_minion_client.name
  }

  ssh_keys = [data.harvester_ssh_key.mysshkey.id]

  tags = {
    role        = "client"
    description = "collector-aggregator"
  }
}

############################
# Workers (x4)
############################
resource "harvester_virtualmachine" "worker" {
  count                = 4
  name                 = "${local.worker_name}-${format("%02d", count.index + 1)}-${random_id.secret.hex}"
  namespace            = var.namespace
  restart_after_update = true
  description          = "Worker node for Merizo batches"
  cpu                  = 6
  memory               = "32Gi"
  efi                  = true
  secure_boot          = false
  run_strategy         = "RerunOnFailure"
  hostname             = "${local.worker_name}-${format("%02d", count.index + 1)}-${random_id.secret.hex}"
  reserved_memory      = "100Mi"
  machine_type         = "q35"

  network_interface {
    name           = "nic-1"
    wait_for_lease = true
    type           = "bridge"
    network_name   = var.network_name
  }

  disk {
    name        = "rootdisk"
    type        = "disk"
    size        = "60Gi"
    bus         = "virtio"
    boot_order  = 1
    image       = data.harvester_image.img.id
    auto_delete = true
  }

  disk {
    name        = "datadisk"
    type        = "disk"
    size        = "250Gi"
    bus         = "virtio"
    auto_delete = true
  }

  cloudinit {
    user_data_secret_name = harvester_cloudinit_secret.cloud_minion_worker.name
  }

  ssh_keys = [data.harvester_ssh_key.mysshkey.id]

  tags = {
    role        = "worker"
    description = "runs-distributed-merizo"
  }
}
