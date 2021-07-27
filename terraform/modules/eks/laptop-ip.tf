data "http" "workstation_external_ip" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  workstation_external_cidr = "${chomp(data.http.workstation_external_ip.body)}/32"
}