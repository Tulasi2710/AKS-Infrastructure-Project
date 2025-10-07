# Performance Reports

This directory contains daily performance reports generated automatically by the GitHub Actions workflow.

## Report Contents

Each daily report includes:

- **Infrastructure Status**: AKS cluster health and node status
- **Application Performance**: E-commerce microservices metrics
- **Resource Utilization**: CPU, memory, and network usage
- **Monitoring Stack**: Prometheus and Grafana status
- **Recent Events**: Kubernetes events and alerts
- **Performance Metrics**: Response times, error rates, and trends
- **Recommendations**: Optimization suggestions based on current usage

## Report Schedule

- **Frequency**: Daily at 8:00 AM UTC
- **Retention**: 90 days in GitHub artifacts
- **Format**: Markdown files with metrics data
- **Location**: `reports/performance-report-YYYY-MM-DD.md`

## Manual Report Generation

To generate a report manually:

```bash
# Trigger the workflow via GitHub Actions UI or CLI
gh workflow run daily-report.yml

# Or via API
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/$OWNER/$REPO/actions/workflows/daily-report.yml/dispatches \
  -d '{"ref":"main"}'
```

## Metrics Sources

- **Kubernetes API**: Pod status, resource usage, events
- **Prometheus**: Application metrics, response times, error rates
- **Azure Monitor**: Infrastructure-level metrics (when integrated)

Reports help track application behavior, identify performance trends, and guide optimization decisions.