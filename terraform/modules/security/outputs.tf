output "ssh_key" {
  value = "${aws_key_pair.ssh_key.id}"
}