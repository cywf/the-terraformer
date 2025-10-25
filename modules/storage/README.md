# Storage Module

This module provisions storage resources across supported cloud platforms, including object storage buckets (AWS S3, Azure Blob Storage, Google Cloud Storage) and block storage (EBS, Managed Disks, Persistent Disks). It supports configurable storage classes, access policies, and lifecycle rules.

## Features
- Multi-cloud support: Works across AWS, Azure, and GCP.
- Storage types: Supports object storage buckets and block storage volumes.
- Configurable parameters: Define storage size, redundancy, encryption, and performance characteristics.
- Security integration: Works with security module to apply IAM policies and network restrictions.
- Lifecycle management: Optionally enable lifecycle rules to manage data retention and archiving.
