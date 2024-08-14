
# Deployment Guide

## Overview

This guide provides instructions for deploying the AI Assistant in various environments, including development, staging, and production. The deployment process involves building Docker images, deploying them to a Kubernetes cluster, and managing configurations and secrets.

---

## Prerequisites

Before you begin, ensure you have the following tools and resources set up:

- **Kubernetes Cluster**: A running Kubernetes cluster.

- **Helm**: Installed and configured on your local machine.
- **Docker Registry**: A place to push your Docker images (e.g., Docker Hub, Google Container Registry).
- **Secrets Management**: A method to securely manage and inject secrets into your Kubernetes cluster.

---

## Deployment Steps

### Step 1: Build Docker Images

First, build the Docker images for all services and push them to your Docker registry. Replace `your-registry` with your actual Docker registry URL.

```bash
docker build -t your-registry/nlp-agent:latest ./services/nlp-agent
docker build -t your-registry/routine-detection-agent:latest ./services/routine-detection-agent
docker build -t your-registry/security-privacy-agent:latest ./services/security-privacy-agent
docker build -t your-registry/feedback-improvement-agent:latest ./services/feedback-improvement-agent
docker build -t your-registry/proactive-assistance-agent:latest ./services/proactive-assistance-agent
docker build -t your-registry/task-management-agent:latest ./services/task-management-agent

# Push images to the registry
docker push your-registry/nlp-agent:latest
docker push your-registry/routine-detection-agent:latest
docker push your-registry/security-privacy-agent:latest
docker push your-registry/feedback-improvement-agent:latest
docker push your-registry/proactive-assistance-agent:latest
docker push your-registry/task-management-agent:latest
```

### Step 2: Deploy to Kubernetes

Use Helm to deploy each service to your Kubernetes cluster. Replace `your-registry` with your actual Docker registry URL in the `values.yaml` files if needed.

```bash
helm install nlp-agent ./charts/nlp-agent
helm install routine-detection-agent ./charts/routine-detection-agent
helm install security-privacy-agent ./charts/security-privacy-agent
helm install feedback-improvement-agent ./charts/feedback-improvement-agent
helm install proactive-assistance-agent ./charts/proactive-assistance-agent
helm install task-management-agent ./charts/task-management-agent
```

### Step 3: Configure Ingress (Optional)

If you need to expose your services externally, you can set up an Ingress controller. Here’s an example of how you might configure Ingress for the NLP Agent service:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
    name: ai-assistant-ingress
spec:
    rules:
    - host: ai-assistant.yourdomain.com
        http:
            paths:
            - path: /nlp
                pathType: Prefix
                backend:
                    service:
                        name: nlp-agent
                        port:
                            number: 5000
```

Apply the Ingress configuration:

```bash
kubectl apply -f ingress.yaml
```

### Step 4: Configure Secrets

Before deploying to production, configure Kubernetes secrets for sensitive data such as database passwords, API keys, and JWT secrets. Here’s an example of how to create a secret:

```bash
kubectl create secret generic prod-secrets \
    --from-literal=postgres-password=your-postgres-password \
    --from-literal=redis-password=your-redis-password \
    --from-literal=jwt-secret=your-jwt-secret
```

Update your Helm charts to reference these secrets in your `values.yaml` files.

### Step 5: Monitoring and Logging

Set up monitoring and logging to ensure you can track the health of your services and troubleshoot any issues. This typically involves deploying Prometheus and Grafana for monitoring and the ELK stack (Elasticsearch, Logstash, Kibana) for logging.

1. **Prometheus**: Monitor metrics from your services.
2. **Grafana**: Visualize metrics and create dashboards.
3. **ELK Stack**: Collect, index, and visualize logs from your services.

### Step 6: Testing the Deployment

After deploying your services, it's crucial to test the deployment to ensure everything is working as expected. This can include:

- Accessing the services via their endpoints.
- Checking the Kubernetes pods and services.
- Monitoring logs for errors or issues.
- Running integration tests to verify service communication.

---

## Environment-Specific Configurations

### Development

- Use `dev-secrets.yaml` for managing secrets during development.
- Deploy using development-specific configurations with Helm:

    ```bash
    helm install nlp-agent ./charts/nlp-agent --values=config/dev-values.yaml
    ```

### Staging

- Mirror the production environment as closely as possible to catch issues before they reach production.
- Use staging-specific secrets and `values.yaml` files.

### Production

- Ensure all secrets are securely managed using Kubernetes secrets.
- Deploy using production-specific configurations:

    ```bash
    helm install nlp-agent ./charts/nlp-agent --values=config/prod-values.yaml
    ```

---

## Rolling Back a Deployment

In case of a failed deployment, you can roll back to a previous version using Helm:

```bash
helm rollback nlp-agent <revision>
```

Check the Helm history to see available revisions:

```bash
helm history nlp-agent
```

---

## Scaling Services

To scale services, use the following command:

```bash
kubectl scale deployment nlp-agent --replicas=3
```

Replace `nlp-agent` with the service you want to scale and adjust the number of replicas as needed.

---

## Conclusion

This guide has walked you through the steps necessary to deploy the AI Assistant system to a Kubernetes cluster. Make sure to customize the deployment process according to your specific environment and requirements.
