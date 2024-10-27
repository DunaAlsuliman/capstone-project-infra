# http server 1
resource "alicloud_instance" "http" {

  availability_zone = data.alicloud_zones.available_zones.zones.0.id
  security_groups   = [alicloud_security_group.http_security_group.id]
  count = 2
  instance_type              = "ecs.g6.large"
  system_disk_category       = "cloud_essd"
  system_disk_size           = 40
  image_id                   = "ubuntu_24_04_x64_20G_alibase_20240812.vhd"
  instance_name              = "http-${count.index}"
  vswitch_id                 = alicloud_vswitch.private.id
  internet_max_bandwidth_out = 0
  internet_charge_type       = "PayByTraffic"
  instance_charge_type       = "PostPaid"
  key_name = alicloud_key_pair.key.key_pair_name

  user_data = templatefile("http-setup.tpl", { redis_host = alicloud_instance.redis.private_ip})
}
# http private ip
  output "http_private_ip" {
  value = alicloud_instance.http.*.private_ip
  }


  # http servers security group & rules

resource "alicloud_security_group" "http_security_group" {
  name        = "http_security_group"
  description = "security group for http instances"
  vpc_id      = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "allow-bastion-to-http" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.http_security_group.id 
  source_security_group_id = alicloud_security_group.bastion_security_group.id
}