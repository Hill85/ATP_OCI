

resource "oci_database_autonomous_database_wallet" "autonomous_database_wallet" {
  autonomous_database_id = oci_database_autonomous_database.autonomous_database.id
  password               = var.wallet
  base64_encode_content  = "true"
}


resource "local_file" "autonomous_database_wallet_file" {
  content_base64 = oci_database_autonomous_database_wallet.autonomous_database_wallet.content
  filename       = "./autonomous_database_wallet.zip" 
} 