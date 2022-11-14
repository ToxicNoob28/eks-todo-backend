aws ecr get-login > login.sh
sed -i "s% -e none % %g" login.sh
minikube start --driver=docker
minikube addons enable ingress
scp -i $(minikube ssh-key) ./login.sh docker@$(minikube ip):/home/docker/
minikube ssh 'bash -s' < ./run.sh
scp -i $(minikube ssh-key) docker@$(minikube ip):/home/docker/.docker/config.json /home/noob/.docker/config.json
kubectl create secret generic todo-app-secret --from-file=.dockerconfigjson=/home/noob/.docker/config.json --type=kubernetes.io/dockerconfigjson
cat ~/.docker/config.json | base64
