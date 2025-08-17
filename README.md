# College-ERP — Beginner-Friendly DevOps Roadmap (Agile + CI/CD + Cloud)

This folder contains a **starter pack** to add CI/CD, security scans, Docker, and Kubernetes deployment to your Django-based College-ERP.

## TL;DR (What to do first)

1. **Put these files** in the root of your repo (alongside `manage.py` and `requirements.txt`).  
2. **Run locally** with Docker Compose to confirm it works.
   ```sh
   docker compose up --build
   ```
3. **Enable GitHub Actions** (or Jenkins) and push to `main` to run tests + build.
4. **Pick AWS** (recommended for beginners). Use the Terraform skeleton to create EKS + ECR.
5. **Deploy to staging** with the Helm chart, run tests, then promote to prod.

---

## Agile DevOps Workflow (Step-by-step)

### 0) Branching & environments
- Branches: `main` (prod), `develop` (staging), feature branches (`feat/*`), bugs (`fix/*`).
- Environments:
  - **Local**: Docker Compose with Postgres.
  - **Staging (EKS)**: Same container on Kubernetes.
  - **Prod (EKS)**: Same chart, scaled and locked down.

### 1) Source control (GitHub/GitLab)
- Commit cleanly, small PRs, include tests.
- Protect `main` with PR + review + green CI required.

### 2) CI (GitHub Actions or Jenkins)
- On every PR: **lint, unit tests, security scans (Bandit, pip-audit)**, build image.
- On merge to `main`: **push image** to registry (GHCR/ECR).

### 3) Security (SAST/DAST/Secrets)
- SAST: Bandit, flake8 (code quality).
- Dependencies: pip-audit.
- DAST: run **OWASP ZAP baseline** against staging after deploy.
- Secrets: Use **AWS Secrets Manager** or **HashiCorp Vault** (advanced). Never hardcode.

### 4) Artifacts
- Container image is your artifact (tag with git SHA). Optionally publish build logs, ZAP report.

### 5) CD (Kubernetes via Helm)
- Staging deploy on every `main` push.
- Manual approval (GitHub Environment protection) promotes to prod:
  ```sh
  helm upgrade --install college-erp ./helm -n erp --set image.tag=<sha>
  ```

### 6) Observability
- Install **Prometheus + Grafana** via Helm for metrics.
- Use **EFK** (Fluent Bit -> OpenSearch/Elasticsearch + Kibana) or CloudWatch for logs.
- Add health probes in Deployment. Create alerts (e.g., high 5xx, pod restarts).

### 7) Cloud data services
- Use **Amazon RDS (PostgreSQL)** for database; **S3** for static/media.
- Configure environment variables for DB + S3 in Helm values and Django settings.

### 8) Agile cadence
- Sprint length: 1–2 weeks.
- Definition of Done: **tests pass, security clean, deploys to staging, PO sign-off**.
- Release: rolling updates to prod with Helm; track in CHANGELOG.

---

## Commands & Useful Snippets

### Build & run locally
```sh
docker compose up --build
```

### Run CI locally (optional)
```sh
pytest -q
flake8 .
bandit -r .
pip-audit -r requirements.txt
```

### Helm deployment
```sh
helm upgrade --install college-erp ./helm -n erp --create-namespace \
  --set image.repository=ghcr.io/<you>/college-erp \
  --set image.tag=<sha> \
  --set secrets.DJANGO_SECRET_KEY=<secret> \
  --set secrets.DB_PASSWORD=<password> \
  --set env.DB_HOST=<rds-endpoint> \
  --set ingress.hosts[0]=staging.your-domain.com
```

### Monitoring (Helm)
```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```

### Logging (EFK)
- Install Fluent Bit to ship logs to OpenSearch or CloudWatch.

---

## Files in this pack

- `Dockerfile`, `docker-compose.yml`, `docker/entrypoint.sh`
- `.github/workflows/ci.yml` (GitHub Actions)
- `Jenkinsfile` (if you prefer Jenkins)
- `helm/` (Deployment, Service, Ingress, Secrets templates)
- `k8s/` raw manifests (alternative to Helm)
- `terraform/` AWS EKS + ECR skeleton
- `sonar-project.properties` (optional SonarQube)
- `security/zap-baseline-notes.txt`

> Start with Docker + GitHub Actions + Helm on staging. Then add Terraform + monitoring/logging. Iterate every sprint.
