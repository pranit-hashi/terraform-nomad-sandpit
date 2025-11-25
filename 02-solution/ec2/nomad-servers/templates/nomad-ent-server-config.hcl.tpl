datacenter = "${datacenter}"
data_dir = "/opt/nomad"
region = "${region}"

bind_addr = "0.0.0.0"

server {
  enabled = true
  bootstrap_expect = 1
  license_path = "/opt/nomad/nomad-ent-license.hclic"
  server_join {
    retry_join = ["${nomad_federation_peer_address}"]
  }
}

# client {
#   enabled = true
# }

ui {
  enabled =  true
}