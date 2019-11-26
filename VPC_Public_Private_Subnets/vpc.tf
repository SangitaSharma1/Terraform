resource "aws_vpc" "vpc_test" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "TestVPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc_test.id}"
  cidr_block              = "${var.public_subnet_cidr}"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"
  tags = {
    Name = "PublicSubnet"
  }
  
}

resource "aws_security_group" "server1" {
    name = "SG_server1"
    description = "Allow incoming ssh and http connection"

   ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
	}

   ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
	}

   
   vpc_id = "${aws_vpc.vpc_test.id}"

    tags = {
        Name = "Server1_SG"
    }
}    


resource "aws_instance" "server1" {
    ami = "${lookup(var.amis, var.aws_region)}"
    availability_zone = "ap-south-1a"
    instance_type = "t2.micro"
    subnet_id = "${aws_subnet.public_subnet.id}"
    key_name = "${var.aws_key_pair}"
    vpc_security_group_ids = ["${aws_security_group.server1.id}"]
    associate_public_ip_address = true
    source_dest_check = false

    tags = {
        Name = "Server 1"
    }
}

resource "aws_eip" "server1" {
    instance = "${aws_instance.server1.id}"
    vpc = true
}


resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.vpc_test.id}"
  cidr_block              = "${var.private_subnet_cidr}"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "PrivateSubnet"
  }
  
}

resource "aws_security_group" "server2" {
    name = "SG_server2"
    description = "Allow incoming ssh and http connection"

   ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
	}

   ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
	}

   
   vpc_id = "${aws_vpc.vpc_test.id}"

    tags = {
        Name = "Server2_SG"
    }
}


resource "aws_instance" "server2" {
    ami = "${lookup(var.amis, var.aws_region)}"
    availability_zone = "ap-south-1a"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_pair}"
    vpc_security_group_ids = ["${aws_security_group.server2.id}"]
    subnet_id = "${aws_subnet.private_subnet.id}"
    source_dest_check = false

    tags = {
        Name = "Server 2"
    }
}
 

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.vpc_test.id}"
  tags = {
    Name = "IG_VPCTest"
  }
  
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vpc_test.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "aws_eip" "test_eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]
  tags = {
    Name = "EIP_VPCTest"
  }
}

resource "aws_nat_gateway" "nat" {
    allocation_id = "${aws_eip.test_eip.id}"
    subnet_id = "${aws_subnet.public_subnet.id}"
    depends_on = ["aws_internet_gateway.gw"]
    tags = {
    Name = "NATGW_VPCTest"
  }
}

resource "aws_route_table" "private_route_table" {
    vpc_id = "${aws_vpc.vpc_test.id}"
    tags = {
        Name = "PrivateRT"
    } 
}
 
resource "aws_route" "private_route" {
	route_table_id  = "${aws_route_table.private_route_table.id}"
	destination_cidr_block = "0.0.0.0/0"
	nat_gateway_id = "${aws_nat_gateway.nat.id}"
}

# Associate subnet 'public_subnet' to public route table
resource "aws_route_table_association" "public_subnet_association" {
    subnet_id = "${aws_subnet.public_subnet.id}"
    route_table_id = "${aws_vpc.vpc_test.main_route_table_id}"
}
 
# Associate subnet 'private_subnet' to private route table
resource "aws_route_table_association" "private_subnet_association" {
    subnet_id = "${aws_subnet.private_subnet.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}




