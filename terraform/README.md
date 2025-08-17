# Terraform (AWS) Quickstart

1. Create/choose a VPC and subnets (public/private). Supply `vpc_id` and `subnet_ids`.
2. `terraform init`
3. `terraform apply`
4. Update kubeconfig:
   ```sh
   aws eks update-kubeconfig --name $(terraform output -raw cluster_name) --region <region>
   ```
5. Install NGINX ingress, cert-manager, and then deploy the Helm chart:
   ```sh
   helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
   helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace

   helm repo add jetstack https://charts.jetstack.io
   helm install cert-manager jetstack/cert-manager -n cert-manager --create-namespace --set installCRDs=true

   helm upgrade --install college-erp ./helm -n erp --create-namespace \
     --set image.repository=<your-ecr-or-ghcr-repo> \
     --set image.tag=latest \
     --set secrets.DJANGO_SECRET_KEY=<secret> \
     --set secrets.DB_PASSWORD=<password> \
     --set env.DB_HOST=<rds-endpoint> \
     --set ingress.hosts[0]=erp.example.com
   ```
