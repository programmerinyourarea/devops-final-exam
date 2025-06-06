# Final Exam
# Infra Config
### Create SSH key on Jenkins Machine
	ssh-keygen -t ed25519 -f ~/.ssh/id_deploy -C "jenkins-deploy-key"

### Move it from Jenkins Machine To Target Machine(s):
	scp ~/.ssh/id_deploy.pub laborant@docker:/home/laborant/authorized_keys.tmp

### Finishing Moving (On Docker Machine):
    sudo mv /home/laborant/authorized_keys.tmp /home/laborant/.ssh/authorized_keys

	sudo chown laborant:laborant /home/laborant/.ssh/authorized_keys

	chmod 600 /home/laborant/.ssh/authorized_keys
### Check That Everything Works:
    ssh -i ~/.ssh/id_deploy laborant@docker
### Get jenkins password:
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
### Login into Jenkis:
	username: admin
    password: generated_password from sudo cat /var/lib/jenkins/secrets/initialAdminPassword
### Get SSH Private Key:
	cat ~/.ssh/id_deploy
### Add Credentials in Jenkins:
	Jenkins->Manage Jenkins->Credentials->(global)->add credentials

    ID: docker_deploy
    username: laborant(or whatever you use)
    private key from cat ~/.ssh/id_deploy from Jenkins Machine.
### Install SSH Agent plugin in Jenkins:
    jenkins->Manage Jenkins->Plugins->SSH Agent && Docker Pipeline
