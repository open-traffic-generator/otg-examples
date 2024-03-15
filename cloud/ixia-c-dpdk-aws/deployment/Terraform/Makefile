deploy: init apply SshKey

init:
	terraform init

apply:
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve

SshKey:
	terraform output SshKey | tail -n +3 | head -n-3 | sed "s/^[ \t]*//" > SshKey.pem