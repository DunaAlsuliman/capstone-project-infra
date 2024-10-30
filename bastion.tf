# Bastion Server
resource "alicloud_instance" "bastion" {

  availability_zone = data.alicloud_zones.available_zones.zones.0.id
  security_groups   = [alicloud_security_group.bastion_security_group.id]

  instance_type              = "ecs.g6.large"
  system_disk_category       = "cloud_essd"
  system_disk_size           = 40
  image_id                   = "ubuntu_24_04_x64_20G_alibase_20240812.vhd"
  instance_name              = "bastion"
  vswitch_id                 = alicloud_vswitch.public.id
  internet_max_bandwidth_out = 100
  internet_charge_type       = "PayByTraffic"
  instance_charge_type       = "PostPaid"
  key_name = alicloud_key_pair.key.key_pair_name

    # user_data = base64encode(file("startup.sh"))
  }

# Bastion server public ip
  output "bastion-public-ip" {
  value = alicloud_instance.bastion.public_ip
  }


# Bastion server security group & rules

  resource "alicloud_security_group" "bastion_security_group" {
  name        = "bastion_security_group"
  description = "security group for public instance"
  vpc_id      = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "allow-browse-bastion" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 1
  security_group_id = alicloud_security_group.bastion_security_group.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow-ssh-to-bastion" {
  type              = "ingress"
  ip_protocol       = "tcp"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.bastion_security_group.id
  cidr_ip           = "0.0.0.0/0"
}
