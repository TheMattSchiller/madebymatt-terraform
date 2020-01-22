Before we deploy any compute resources we are going to lay the networking foundation for our kubernetes cluster. Terraform is my preferred tool to create and manage VPC networking resources.

In order to use terraform with GCP we need to create a terraform service account which has only the necessary IAM permissions for terraform to function properly.

All calls to the gcloud API require that you be authenticated. Before each session you will need to login with `gcloud auth login` this will open your webbrowser and take you to the GCP login page. Login with your admin credentials.
Then create the terraform role with the following commands:
```
$ gcloud iam service-accounts create terraform
$ gcloud projects add-iam-policy-binding i-enterprise-264400 --member "serviceAccount:terraform@i-enterprise-264400.iam.gserviceaccount.com" --role "roles/compute.networkAdmin"
```
Generate the key file for the role and store it somewhere secure. We will loop back to this when we create our secret store.
```
$  gcloud iam service-accounts keys create terraform.json --iam-account terraform@i-enterprise-264400.iam.gserviceaccount.com
```
Export supply the path to the key file to terraform using the following environment variable
```
$ export GOOGLE_CLOUD_KEYFILE_JSON=path/to/keyfile
```
Now we will create a basic VPC with two internal and two external subnets using the follwing configuration. To keep things simple and organized we will use /24 subnet masks and will increment each subnet by .1 so that 10.5.0.0/24 - 10.5.1.0/24 are internal and 10.5.2.0/24 - 10.5.3.0/24 are external.
Our terraform file at this point has 3 different types of resources. The first resource is our `provider` resource. This specifies the cloud provider we are using (google), our default project name, default region, and default zone. If a resource is missing any of these values, then the provider defaults we configure here will be used.
 
```
provider "google" {
  project = "i-enterprise-264400"
  region  = "us-west1"
  zone    = "us-west1-a"
}
```
Next we will create the network resource. The network resource will be referred to by all of our subnet resources.
```
resource "google_compute_network" "kubernetes" {
  name                    = "kubernetes"
  auto_create_subnetworks = "false"
}
```
Now we will add in our four subnets with their respective names
```
resource "google_compute_subnetwork" "int-us-west1-a" {
  name = "int-us-west1-a"
  ip_cidr_range = "10.5.0.0/24"
  region = "us-west1"
  network = google_compute_network.kubernetes.self_link
}

resource "google_compute_subnetwork" "int-us-west1-b" {
  name = "int-us-west1-b"
  ip_cidr_range = "10.5.1.0/24"
  region = "us-west1"
  network = google_compute_network.kubernetes.self_link
}

resource "google_compute_subnetwork" "ext-us-west1-a" {
  name = "ext-us-west1-a"
  ip_cidr_range = "10.5.2.0/24"
  region = "us-west1"
  network = google_compute_network.kubernetes.self_link
}

resource "google_compute_subnetwork" "ext-us-west1-b" {
  name = "ext-us-west1-b"
  ip_cidr_range = "10.5.3.0/24"
  region = "us-west1"
  network = google_compute_network.kubernetes.self_link
}
```
Maintaining order in this file is not explicitly required, but it will make our life much easier, therefore we will order the configuration as follows
```
provider "google" {
  project = "i-enterprise-264400"
  region  = "us-west1"
  zone    = "us-west1-a"
}

resource "google_compute_subnetwork" "int-us-west1-a" {
  name = "int-us-west1-a"
  ip_cidr_range = "10.5.0.0/24"
  region = "us-west1"
  network = google_compute_network.kubernetes.self_link
}

resource "google_compute_subnetwork" "int-us-west1-b" {
  name = "int-us-west1-b"
  ip_cidr_range = "10.5.1.0/24"
  region = "us-west1"
  network = google_compute_network.kubernetes.self_link
}

resource "google_compute_subnetwork" "ext-us-west1-a" {
  name = "ext-us-west1-a"
  ip_cidr_range = "10.5.2.0/24"
  region = "us-west1"
  network = google_compute_network.kubernetes.self_link
}

resource "google_compute_subnetwork" "ext-us-west1-b" {
  name = "ext-us-west1-b"
  ip_cidr_range = "10.5.3.0/24"
  region = "us-west1"
  network = google_compute_network.kubernetes.self_link
}

resource "google_compute_network" "kubernetes" {
  name                    = "kubernetes"
  auto_create_subnetworks = "false"
}
```
In the terraform folder containing your `network.tf` file run the following command to initialize terraform so that it will install necessary plugins. This will only need to be run once in the directory containing `network.tf` unless you use another provider later.
```
$ terraform init
```
Run the following command to see which actions terraform will perform
```
$ terraform plan
```
The resulting output explains what terraform will do. Because this is the first time we are running terraform, it is only going to create the network and subnetworks we have defined in the config. The following config generates the resulting output

```
An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_compute_network.kubernetes will be created
  + resource "google_compute_network" "kubernetes" {
      + auto_create_subnetworks         = false
      + delete_default_routes_on_create = false
      + gateway_ipv4                    = (known after apply)
      + id                              = (known after apply)
      + ipv4_range                      = (known after apply)
      + name                            = "kubernetes"
      + project                         = (known after apply)
      + routing_mode                    = (known after apply)
      + self_link                       = (known after apply)
    }

  # google_compute_subnetwork.ext-us-west1-a will be created
  + resource "google_compute_subnetwork" "ext-us-west1-a" {
      + creation_timestamp = (known after apply)
      + enable_flow_logs   = (known after apply)
      + fingerprint        = (known after apply)
      + gateway_address    = (known after apply)
      + id                 = (known after apply)
      + ip_cidr_range      = "10.5.2.0/24"
      + name               = "ext-us-west1-a"
      + network            = (known after apply)
      + project            = (known after apply)
      + region             = "us-west1"
      + secondary_ip_range = (known after apply)
      + self_link          = (known after apply)
    }

  # google_compute_subnetwork.ext-us-west1-b will be created
  + resource "google_compute_subnetwork" "ext-us-west1-b" {
      + creation_timestamp = (known after apply)
      + enable_flow_logs   = (known after apply)
      + fingerprint        = (known after apply)
      + gateway_address    = (known after apply)
      + id                 = (known after apply)
      + ip_cidr_range      = "10.5.3.0/24"
      + name               = "ext-us-west1-b"
      + network            = (known after apply)
      + project            = (known after apply)
      + region             = "us-west1"
      + secondary_ip_range = (known after apply)
      + self_link          = (known after apply)
    }

  # google_compute_subnetwork.int-us-west1-a will be created
  + resource "google_compute_subnetwork" "int-us-west1-a" {
      + creation_timestamp = (known after apply)
      + enable_flow_logs   = (known after apply)
      + fingerprint        = (known after apply)
      + gateway_address    = (known after apply)
      + id                 = (known after apply)
      + ip_cidr_range      = "10.5.0.0/24"
      + name               = "int-us-west1-a"
      + network            = (known after apply)
      + project            = (known after apply)
      + region             = "us-west1"
      + secondary_ip_range = (known after apply)
      + self_link          = (known after apply)
    }

  # google_compute_subnetwork.int-us-west1-b will be created
  + resource "google_compute_subnetwork" "int-us-west1-b" {
      + creation_timestamp = (known after apply)
      + enable_flow_logs   = (known after apply)
      + fingerprint        = (known after apply)
      + gateway_address    = (known after apply)
      + id                 = (known after apply)
      + ip_cidr_range      = "10.5.1.0/24"
      + name               = "int-us-west1-b"
      + network            = (known after apply)
      + project            = (known after apply)
      + region             = "us-west1"
      + secondary_ip_range = (known after apply)
      + self_link          = (known after apply)
    }

Plan: 5 to add, 0 to change, 0 to destroy.
```
To apply these changes the following to apply and confirm
```
$ terraform apply
$ yes
```
Because we are creating a new VPC, a default route will be generated by GCP. This route will generate the path to the internet, so that all of our subnets are public. Now we will work to make our two internal subnets private. This requires the creation an NAT gateway, which cost per GB of transfer on GCP (rather than an expensive instance pricing on AWS). Lets add the following code to our `network.tf` file in order to create one NAT gateway for our VPC.
This adds 3 new resources to our terraform code which are required for an NAT gateway. The first is a `google_compute_route`. In order to add NAT to this router we need to add a public ip address and an nat configuration. GCP will allocate us a public ip address when we use the `google_compute_address` resource. Then we tie our configuration together with the `google_compute_router_nat` resource. This resource specifies which router to use, which ip address to use, and which subnets to allow NAT. For the subnets we specify our two internal subnets we have created above.
```
resource "google_compute_router" "kube-router-us-west1" {
  name    = "kube-router-us-west1"
  region  = google_compute_subnetwork.ext-us-west1-a.region
  network = google_compute_network.kubernetes.self_link
}

resource "google_compute_address" "kube-router-us-west1-nat-ip-0" {
  count  = 1
  name   = "kube-router-us-west1-nat-ip-0"
  region = google_compute_subnetwork.ext-us-west1-a.region
}

resource "google_compute_router_nat" "kube-router-us-west1-nat" {
  name   = "kube-router-us-west1-nat"
  router = google_compute_router.kube-router-us-west1.name
  region = google_compute_router.kube-router-us-west1.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.kube-router-us-west1-nat-ip-0.*.self_link

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.int-us-west1-a.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
    subnetwork {
    name                    = google_compute_subnetwork.int-us-west1-b.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
```
With our four subnets and NAT gateway configured it is now time to add routing tables into our terraform code and to apply those routes to our internal and external subnets. This is the stage that actually configures the internal and external subnets as internal or external. The internal subnets need to have the NAT gateway as their default route, and the external subnets will persist their configuration where the default route is the internet gateway. This ensures that our internal resources can access the internet using Network Address Translation and will be masked behind the public ip address of the NAT gateway.



Now we need to add firewall rules for our VPC. The default role `Compute Network Admin` does not have permission to create firewall rules. Normally we would cherry-pick each of the permissions for our terraform user so that it has the least permissions necessary to perform its function, but in this example we can simply create a new role from the `Compute Network Admin` and add the `compute.firewalls.create` `compute.firewalls.delete` and `compute.firewalls.update` permissions for our project to a new role, which we will then assign to the terraform service account.
We will create a new terraform file in our terraform directory which will be called `firewall.tf`. This will allow us to keep our terraform code more organized for later. In this file we will create two rules which will apply to our kubernetes network. The first rule will allow all internal communication between our instances we will place in our 4 subnets. The second rule will allow SSH and the kubernetes API through the firewall over the internet
```
resource "google_compute_firewall" "kube-int-us-west1" {
  name    = "kube-int-us-west1"
  network = google_compute_network.kubernetes.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_ranges = ["10.5.0.0/24", "10.5.1.0/24", "10.5.2.0/24", "10.5.3.0/24"]

}

resource "google_compute_firewall" "kube-ext-us-west1" {
  name    = "kube-ext-us-west1"
  network = google_compute_network.kubernetes.name

  allow {
    protocol = "tcp"
    ports = ["22", "6443"]
  }

  source_ranges = ["0.0.0.0/0"]

}
```

This sets up our basic VPC configuration. Now we need to add some instances. We are going to start by creating our kubernetes instances using cloudbuild, packer, and gradle. Once our instances are built we will return to write more terraform code which will deploy instances using our custom images. See the packer configuration here:

(the next section requires having built images using cloudbuild/packer)

Now we will create our `kube-instances.tf` file. This will deploy our controller and nodes into our subnets `ext-us-west1-a` and `ext-us-west1-b`. The architecture of kubernetes provides NAT within the cluster, therefore 