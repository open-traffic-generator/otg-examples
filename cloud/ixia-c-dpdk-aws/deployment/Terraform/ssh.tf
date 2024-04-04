resource "aws_key_pair" "SshKey" {
	key_name = local.SshKeyName
	public_key = tls_private_key.SshKey.public_key_openssh
}

resource "tls_private_key" "SshKey" {
	algorithm = local.SshKeyAlgorithm
	rsa_bits = local.SshKeyRsaBits
}