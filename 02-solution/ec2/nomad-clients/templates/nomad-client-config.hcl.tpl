datacenter = "${datacenter}"
data_dir = "/opt/nomad"
region = "${region}"

bind_addr = "0.0.0.0"

client {
  alloc_dir = "/opt/nomad/alloc"
  alloc_mounts_dir = "/opt/nomad/alloc_mounts"
  enabled = true
  server_join {
    retry_join = [ "provider=aws tag_key=Name tag_value=${deployment_id}-nomad-server" ]
  }
}