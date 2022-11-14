eksctl create cluster --name=todo-app-eks --region=ap-south-1 --zones=ap-south-1a,ap-south-1b,ap-south-1c --without-nodegroup
kubectl config view --minify
eksctl get cluster
eksctl utils associate-iam-oidc-provider --region ap-south-1 --cluster todo-app-eks --approve
eksctl create nodegroup --cluster=todo-app-eks --region=ap-south-1 --name=todo-app-eks-ng-public1 --node-type=t3.medium --nodes=2 --nodes-min=2 --nodes-max=4 --node-volume-size=20 --ssh-public-key=demo-ecs --ssh-access --managed --asg-access --external-dns-access --full-ecr-access --appmesh-access --alb-ingress-access                        
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.4/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json
eksctl create iamserviceaccount   --cluster=todo-app-eks   --namespace=kube-system   --name=aws-load-balancer-controller   --role-name "AmazonEKSLoadBalancerControllerRole"   --attach-policy-arn=arn:aws:iam::036724582617:policy/AWSLoadBalancerControllerIAMPolicy   --approve --override-existing-serviceaccounts
helm delete aws-alb-ingress-controller -n kube-system
helm delete aws-load-balancer-controller -n kube-system
helm repo add eks https://aws.github.io/eks-charts
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
helm install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system --set clusterName=todo-app-eks --set serviceAccount.create=false --set serviceAccount.name=aws-load-balancer-controller
kubectl get deployment -n kube-system aws-load-balancer-controller
kubectl apply -f todo-app-deployment.yaml
#https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html
