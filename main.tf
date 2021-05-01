variable "compartment_ocid" {}
variable "region" {}
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "admin_password" {}
variable "wallet" {}

provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  fingerprint = var.fingerprint
  private_key = var.private_key_path
  region = var.region
}

variable "ad_region_mapping" {
  type = map(string)

  default = {
    sa-saopaulo-1 = 1
  }
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.ad_region_mapping[var.region]
}

variable "db_workload" {
  default = "OLTP"
}


variable "autonomous_database_freeform_tags" {
  default = {
    "Department" = "RH"
  }
}

variable "autonomous_database_license_model" {
  default = "LICENSE_INCLUDED"
}

variable "autonomous_database_is_dedicated" {
  default = false

}

resource "oci_database_autonomous_database_wallet" "autonomous_database_wallet" {
  autonomous_database_id = oci_database_autonomous_database.autonomous_database.id
  password               = var.wallet
  base64_encode_content  = "true"
}


resource "local_file" "autonomous_database_wallet_file" {
  content_base64 = oci_database_autonomous_database_wallet.autonomous_database_wallet.content
  filename       = "autonomous_database_wallet.zip"
}


resource "oci_database_autonomous_database" "autonomous_database" {  
  admin_password           = var.admin_password
  compartment_id           = var.compartment_ocid
  cpu_core_count           = "1"
  data_storage_size_in_tbs = "1"
  db_name                  = "dbrh"
  is_free_tier             = true  
  db_workload                                    = var.db_workload
  display_name                                   = "Projeto Final OCI"
  is_auto_scaling_enabled                        = "false"
  is_preview_version_with_service_terms_accepted = "false"
  license_model = var.autonomous_database_license_model
  is_dedicated = var.autonomous_database_is_dedicated
  freeform_tags = var.autonomous_database_freeform_tags
}



data "oci_database_autonomous_databases" "autonomous_databases" {  
  compartment_id = var.compartment_ocid
  display_name = oci_database_autonomous_database.autonomous_database.display_name
  db_workload  = var.db_workload
}

output "autonomous_databases" {
  value = data.oci_database_autonomous_databases.autonomous_databases.autonomous_databases
}

output "autonomous_database_high_connection_string" {
  value = lookup(oci_database_autonomous_database.autonomous_database.connection_strings.0.all_connection_strings, "high", "unavailable")
}
