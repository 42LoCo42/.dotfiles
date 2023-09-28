help:
	just -l

deploy:
	deploy -s --remote-build --magic-rollback=false --ssh-opts="-t"
