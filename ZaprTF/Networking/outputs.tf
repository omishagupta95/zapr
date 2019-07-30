output "vpc_name" {
  value = "${google_compute_network.knolskape-staging-vpc.name}"
}

output "region_name" {
  value = "${google_compute_subnetwork.staging-subnet-public.region}"
}

output "subnet_name" {
  value ="${google_compute_subnetwork.staging-subnet-public.name}"
}

