variable "do_token" {}
variable "cloudflare_email" {}
variable "cloudflare_token" {}

variable "node_count" {
  default = 3
}

provider "digitalocean" {
  token = var.do_token
}

provider "cloudflare" {
  version = "~> 1.0"
  email = var.cloudflare_email
  token = var.cloudflare_token
}


data "digitalocean_ssh_key" "ondrejsika" {
  name = "ondrejsika"
}

resource "digitalocean_droplet" "node" {
  count = var.node_count

  image  = "docker-18-04"
  name   = "rook${count.index}"
  region = "fra1"
  size   = "s-2vcpu-4gb"
  ssh_keys = [
    data.digitalocean_ssh_key.ondrejsika.id
  ]
  tags = ["rook-node"]
}

resource "digitalocean_volume" "volume" {
  count  = var.node_count

  name   = "rook-${count.index}"
  region = "fra1"
  size   = 30
}

resource "digitalocean_volume_attachment" "foobar" {
  count  = var.node_count

  droplet_id = digitalocean_droplet.node[count.index].id
  volume_id  = digitalocean_volume.volume[count.index].id
}

resource "cloudflare_record" "node_record" {
  count = var.node_count

  domain = "sikademo.com"
  name   = "rook${count.index}"
  value  = digitalocean_droplet.node[count.index].ipv4_address
  type   = "A"
  proxied = false
}

resource "cloudflare_record" "node_wildcard" {
  count = var.node_count

  domain = "sikademo.com"
  name   = "*.rook${count.index}"
  value  = "rook${count.index}.sikademo.com"
  type   = "CNAME"
  proxied = false
}

resource "digitalocean_loadbalancer" "rook" {
  name = "rook"
  region = "fra1"

  droplet_tag = "rook-node"

  healthcheck {
    port = 30001
    protocol = "tcp"
  }

  forwarding_rule {
    entry_port  = 80
    target_port = 30001
    entry_protocol = "tcp"
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port  = 443
    target_port = 30002
    entry_protocol = "tcp"
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port  = 8080
    target_port = 30003
    entry_protocol = "tcp"
    target_protocol = "tcp"
  }
}

resource "cloudflare_record" "cluster_record" {
  domain = "sikademo.com"
  name   = "rook"
  value  = digitalocean_loadbalancer.rook.ip
  type   = "A"
  proxied = false
}

resource "cloudflare_record" "cluster_wildcard" {
  domain = "sikademo.com"
  name   = "*.rook"
  value  = "rook.sikademo.com"
  type   = "CNAME"
  proxied = false
}
