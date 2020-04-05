# Infrastructure for Example Rook Ceph Storage on Digital Ocean managed by Terraform

    2020 Ondrej Sika <ondrej@ondrejsika.com>
    https://github.com/ondrejsika/terraform-do-rook-ceph-example


## Setup

Setup infrastructure

```
terraform init
terraform apply
```

Apply Ansible playbook

```
pipenv install
./ansible-apply.sh
```

Install Traefik Ingress

```
kubectl apply -f https://raw.githubusercontent.com/ondrejsika/kubernetes-ingress-traefik/master/ingress-traefik.yml
```

Continue with Rancher & Rook ...
