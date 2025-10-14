output "salt_master_ip" {
  description = "Salt master (management) IP"
  value       = harvester_virtualmachine.salt_master.network_interface[0].ip_address
}

output "client_ip" {
  description = "Client (aggregator) IP"
  value       = harvester_virtualmachine.client.network_interface[0].ip_address
}

output "worker_ips" {
  description = "Worker node IPs"
  value       = [for w in harvester_virtualmachine.worker : w.network_interface[0].ip_address]
}
