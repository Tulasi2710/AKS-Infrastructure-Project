#!/bin/bash

# AKS Infrastructure Setup Script
# This script helps you get started with the AKS infrastructure deployment

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  AKS Infrastructure Setup${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check Azure CLI
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    print_success "Azure CLI is installed"
    
    # Check Terraform
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    print_success "Terraform is installed"
    
    # Check Terraform version
    TF_VERSION=$(terraform version -json | jq -r '.terraform_version')
    print_success "Terraform version: $TF_VERSION"
    
    # Check if logged into Azure
    if ! az account show &> /dev/null; then
        print_warning "Not logged into Azure CLI. Please run 'az login' first."
        read -p "Would you like to log in now? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            az login
            print_success "Logged into Azure"
        else
            print_error "Azure login required. Exiting."
            exit 1
        fi
    else
        print_success "Already logged into Azure CLI"
    fi
}

# Setup configuration
setup_config() {
    print_info "Setting up configuration..."
    
    cd terraform/environments/dev
    
    # Copy terraform.tfvars if it doesn't exist
    if [ ! -f "terraform.tfvars" ]; then
        cp terraform.tfvars.template terraform.tfvars
        print_success "Created terraform.tfvars from template"
        print_warning "Please edit terraform.tfvars with your specific values before continuing"
        
        read -p "Would you like to edit terraform.tfvars now? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            ${EDITOR:-nano} terraform.tfvars
        fi
    else
        print_success "terraform.tfvars already exists"
    fi
    
    cd ../../..
}

# Create backend storage
create_backend() {
    print_info "Setting up Terraform backend..."
    
    read -p "Would you like to create a storage account for remote state? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Get current subscription
        SUBSCRIPTION_ID=$(az account show --query id --output tsv)
        print_info "Using subscription: $SUBSCRIPTION_ID"
        
        # Generate unique storage account name
        TIMESTAMP=$(date +%s)
        STORAGE_ACCOUNT="sttfstate$TIMESTAMP"
        RESOURCE_GROUP="rg-tfstate"
        LOCATION="East US"
        
        print_info "Creating resource group: $RESOURCE_GROUP"
        az group create --name "$RESOURCE_GROUP" --location "$LOCATION"
        
        print_info "Creating storage account: $STORAGE_ACCOUNT"
        az storage account create \
            --name "$STORAGE_ACCOUNT" \
            --resource-group "$RESOURCE_GROUP" \
            --location "$LOCATION" \
            --sku "Standard_LRS" \
            --kind "StorageV2"
        
        print_info "Creating storage container: tfstate"
        az storage container create \
            --name "tfstate" \
            --account-name "$STORAGE_ACCOUNT"
        
        print_success "Backend storage created successfully!"
        print_info "Storage Account: $STORAGE_ACCOUNT"
        print_info "Resource Group: $RESOURCE_GROUP"
        print_warning "Update your CI/CD pipeline variables with these values"
        
        # Save to file for reference
        cat > backend-config.txt << EOF
# Terraform Backend Configuration
# Use these values in your CI/CD pipeline

TFSTATE_RESOURCE_GROUP="$RESOURCE_GROUP"
TFSTATE_STORAGE_ACCOUNT="$STORAGE_ACCOUNT"
TFSTATE_CONTAINER_NAME="tfstate"

# Backend configuration block for main.tf:
terraform {
  backend "azurerm" {
    resource_group_name  = "$RESOURCE_GROUP"
    storage_account_name = "$STORAGE_ACCOUNT"
    container_name       = "tfstate"
    key                 = "dev.terraform.tfstate"
  }
}
EOF
        print_success "Backend configuration saved to backend-config.txt"
    fi
}

# Initialize and validate Terraform
init_terraform() {
    print_info "Initializing Terraform..."
    
    cd terraform/environments/dev
    
    # Initialize Terraform
    terraform init
    print_success "Terraform initialized"
    
    # Validate configuration
    terraform validate
    print_success "Terraform configuration is valid"
    
    # Format check
    terraform fmt -check -recursive ../..
    print_success "Terraform formatting is correct"
    
    cd ../../..
}

# Plan deployment
plan_deployment() {
    print_info "Planning Terraform deployment..."
    
    cd terraform/environments/dev
    
    terraform plan -var-file="terraform.tfvars" -out="tfplan"
    print_success "Terraform plan completed successfully"
    
    print_warning "Review the plan above before proceeding"
    read -p "Would you like to apply this plan? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    else
        print_info "Plan saved as 'tfplan'. You can apply it later with: terraform apply tfplan"
        cd ../../..
        exit 0
    fi
    
    cd ../../..
}

# Apply deployment
apply_deployment() {
    print_info "Applying Terraform deployment..."
    
    cd terraform/environments/dev
    
    terraform apply "tfplan"
    print_success "Infrastructure deployed successfully!"
    
    # Show outputs
    echo
    print_info "Deployment outputs:"
    terraform output
    
    cd ../../..
}

# Configure kubectl
setup_kubectl() {
    print_info "Configuring kubectl..."
    
    cd terraform/environments/dev
    
    # Get outputs
    RESOURCE_GROUP=$(terraform output -raw resource_group_name)
    CLUSTER_NAME=$(terraform output -raw aks_cluster_name)
    
    cd ../../..
    
    # Get AKS credentials
    az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" --overwrite-existing
    print_success "kubectl configured for AKS cluster"
    
    # Test cluster connection
    print_info "Testing cluster connection..."
    kubectl get nodes
    print_success "Successfully connected to AKS cluster"
}

# Main execution
main() {
    print_header
    
    print_info "This script will help you set up the AKS infrastructure"
    print_info "Make sure you have reviewed the documentation first"
    echo
    
    read -p "Continue with setup? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Setup cancelled"
        exit 0
    fi
    
    check_prerequisites
    setup_config
    create_backend
    init_terraform
    plan_deployment
    apply_deployment
    setup_kubectl
    
    echo
    print_success "🎉 AKS Infrastructure setup completed successfully!"
    print_info "Next steps:"
    echo "  1. Review the deployed resources in Azure Portal"
    echo "  2. Test kubectl access: kubectl get nodes"
    echo "  3. Set up CI/CD pipeline with the backend configuration"
    echo "  4. Proceed to Phase 2: Application deployment"
    echo
    print_info "For more information, see docs/deployment-guide.md"
}

# Run main function
main "$@"