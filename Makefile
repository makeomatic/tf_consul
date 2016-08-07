
update:
	git submodule update --remote tf_compute
	ln -f tf_compute/aws.tf aws/
