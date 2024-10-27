# redis server
resource "alicloud_instance" "redis" {

  availability_zone = data.alicloud_zones.available_zones.zones.0.id
  security_groups   = [alicloud_security_group.redis_security_group.id]

  instance_type              = "ecs.g6.large"
  system_disk_category       = "cloud_essd"
  system_disk_size           = 40
  image_id                   = "ubuntu_24_04_x64_20G_alibase_20240812.vhd"
  instance_name              = "redis"
  vswitch_id                 = alicloud_vswitch.private.id
  internet_max_bandwidth_out = 0
  internet_charge_type       = "PayByTraffic"
  instance_charge_type       = "PostPaid"
  key_name = alicloud_key_pair.key.key_pair_name

  user_data = base64encode(file("redis-setup.sh"))
  }

# redis server private ip
  output "redis_private_ip" {
  value = alicloud_instance.redis.private_ip
  }

# redis security group & rules
resource "alicloud_security_group" "redis_security_group" {
  name        = "redis_security_group"
  description = "security group for private instance"
  vpc_id      = alicloud_vpc.vpc.id
}


resource "alicloud_security_group_rule" "allow-bastion-to-redis" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.redis_security_group.id 
  source_security_group_id = alicloud_security_group.bastion_security_group.id
}

resource "alicloud_security_group_rule" "allow-web-to-redis" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "6379/6379"
  priority          = 1
  security_group_id = alicloud_security_group.redis_security_group.id 
  source_security_group_id = alicloud_security_group.http_security_group.id
}


