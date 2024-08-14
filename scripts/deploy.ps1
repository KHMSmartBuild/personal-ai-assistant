# Deploy all services using Helm
helm upgrade --install nlp-agent ./charts/nlp-agent
helm upgrade --install routine-detection-agent ./charts/routine-detection-agent
helm upgrade --install preference-learning-agent ./charts/preference-learning-agent
helm upgrade --install task-management-agent ./charts/task-management-agent
helm upgrade --install security-privacy-agent ./charts/security-privacy-agent
helm upgrade --install feedback-improvement-agent ./charts/feedback-improvement-agent
helm upgrade --install proactive-assistance-agent ./charts/proactive-assistance-agent

Write-Host "Deployment completed."
