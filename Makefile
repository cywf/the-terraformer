.PHONY: help init validate fmt lint security clean test docs

# Default target
.DEFAULT_GOAL := help

# Variables
TERRAFORM := terraform
EXAMPLES := examples/aws-simple examples/azure-simple examples/gcp-simple
MODULES := modules/networking modules/compute modules/storage modules/kubernetes

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## Initialize all examples
	@echo "Initializing Terraform examples..."
	@for dir in $(EXAMPLES); do \
		echo "Initializing $$dir..."; \
		cd $$dir && $(TERRAFORM) init -backend=false && cd ../..; \
	done

validate: ## Validate all Terraform configurations
	@echo "Validating Terraform configurations..."
	@for dir in $(EXAMPLES) $(MODULES); do \
		echo "Validating $$dir..."; \
		cd $$dir && $(TERRAFORM) init -backend=false > /dev/null && $(TERRAFORM) validate && cd ../..; \
	done

fmt: ## Format all Terraform files
	@echo "Formatting Terraform files..."
	@$(TERRAFORM) fmt -recursive .

fmt-check: ## Check if Terraform files are formatted
	@echo "Checking Terraform formatting..."
	@$(TERRAFORM) fmt -check -recursive .

lint: ## Run linting checks
	@echo "Running tflint..."
	@command -v tflint >/dev/null 2>&1 || { echo "tflint not installed. Install from https://github.com/terraform-linters/tflint"; exit 1; }
	@tflint --init
	@tflint --recursive

security: ## Run security scans
	@echo "Running security scans..."
	@echo "Running tfsec..."
	@command -v tfsec >/dev/null 2>&1 || { echo "tfsec not installed. Install from https://github.com/aquasecurity/tfsec"; exit 1; }
	@tfsec .
	@echo ""
	@echo "Running checkov..."
	@command -v checkov >/dev/null 2>&1 || { echo "checkov not installed. Install with: pip install checkov"; exit 1; }
	@checkov -d . --framework terraform --quiet

clean: ## Clean Terraform files
	@echo "Cleaning Terraform files..."
	@find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	@find . -type f -name "*.tfstate*" -delete 2>/dev/null || true
	@echo "Cleanup complete"

test-aws: ## Test AWS example
	@echo "Testing AWS example..."
	@cd examples/aws-simple && \
		$(TERRAFORM) init -backend=false && \
		$(TERRAFORM) validate && \
		$(TERRAFORM) plan -out=tfplan.out && \
		rm -f tfplan.out

test-azure: ## Test Azure example
	@echo "Testing Azure example..."
	@cd examples/azure-simple && \
		$(TERRAFORM) init -backend=false && \
		$(TERRAFORM) validate && \
		$(TERRAFORM) plan -out=tfplan.out && \
		rm -f tfplan.out

test-gcp: ## Test GCP example
	@echo "Testing GCP example..."
	@cd examples/gcp-simple && \
		$(TERRAFORM) init -backend=false && \
		$(TERRAFORM) validate && \
		$(TERRAFORM) plan -out=tfplan.out && \
		rm -f tfplan.out

test: validate ## Run all tests
	@echo "Running all tests..."
	@$(MAKE) fmt-check
	@$(MAKE) validate
	@echo "All tests passed!"

docs: ## Generate documentation
	@echo "Generating documentation..."
	@command -v terraform-docs >/dev/null 2>&1 || { echo "terraform-docs not installed. Install from https://github.com/terraform-docs/terraform-docs"; exit 1; }
	@for dir in $(MODULES); do \
		echo "Generating docs for $$dir..."; \
		terraform-docs markdown table --output-file README.md --output-mode inject $$dir; \
	done

install-tools: ## Install required tools
	@echo "Installing required tools..."
	@echo "Installing tflint..."
	@curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash || echo "Failed to install tflint"
	@echo "Installing tfsec..."
	@brew install tfsec || echo "Install tfsec manually from https://github.com/aquasecurity/tfsec"
	@echo "Installing checkov..."
	@pip install checkov || echo "Failed to install checkov"
	@echo "Installing terraform-docs..."
	@brew install terraform-docs || echo "Install terraform-docs manually from https://github.com/terraform-docs/terraform-docs"

init-project: ## Initialize a new project (usage: make init-project NAME=myproject PROVIDER=aws)
	@./scripts/init-project.sh $(NAME) $(PROVIDER)

pre-commit: ## Run pre-commit checks
	@$(MAKE) fmt
	@$(MAKE) validate
	@echo "Pre-commit checks passed!"

ci: ## Run CI checks locally
	@echo "Running CI checks..."
	@$(MAKE) fmt-check
	@$(MAKE) validate
	@$(MAKE) security
	@echo "CI checks complete!"

version: ## Show Terraform version
	@$(TERRAFORM) version
