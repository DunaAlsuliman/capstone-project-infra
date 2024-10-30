resource "alicloud_vpc" "vpc" {
  cidr_block  = "10.0.0.0/8"
  vpc_name    = "capstone-project"
}

data "alicloud_zones" "available_zones" {
  available_resource_creation = "VSwitch"
}
# vswitches
resource "alicloud_vswitch" "public" {
  vpc_id     = alicloud_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  zone_id    = data.alicloud_zones.available_zones.zones.0.id
  vswitch_name = "public"
}

resource "alicloud_vswitch" "public2" {
  vpc_id     = alicloud_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  zone_id    = data.alicloud_zones.available_zones.zones.1.id
  vswitch_name = "public2"
}

resource "alicloud_vswitch" "private" {
  vpc_id     = alicloud_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  zone_id    = data.alicloud_zones.available_zones.zones.0.id
  vswitch_name = "private"
}

resource "alicloud_nat_gateway" "nat_gateway" {
  vpc_id           = alicloud_vpc.vpc.id
  nat_gateway_name = "nat_gateway"
  payment_type     = "PayAsYouGo"
  vswitch_id       = alicloud_vswitch.public.id
  nat_type         = "Enhanced"
}


resource "alicloud_eip_address" "nat_address" {
  address_name = "nat"
  netmode = "public"
  bandwidth = "100"
  internet_charge_type = "PayByTraffic"
  payment_type = "PayAsYouGo"

}

resource "alicloud_eip_association" "nat_association" {
  allocation_id = alicloud_eip_address.nat_address.id
  instance_id   = alicloud_nat_gateway.nat_gateway.id
  instance_type = "Nat"
}

resource "alicloud_snat_entry" "snat_private" {
  snat_table_id     = alicloud_nat_gateway.nat_gateway.snat_table_ids
  source_vswitch_id = alicloud_vswitch.private.id
  snat_ip           = alicloud_eip_address.nat_address.ip_address
}

# route tables

resource "alicloud_route_table" "private" {
  vpc_id           = alicloud_vpc.vpc.id
  route_table_name = "private route table"
  associate_type   = "VSwitch"
}


resource "alicloud_route_table_attachment" "route_table_attachment" {
  vswitch_id     = alicloud_vswitch.private.id
  route_table_id = alicloud_route_table.private.id
}

resource "alicloud_route_entry" "entry" {
  route_table_id        = alicloud_route_table.private.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "NatGateway"
  nexthop_id            = alicloud_nat_gateway.nat_gateway.id
}



