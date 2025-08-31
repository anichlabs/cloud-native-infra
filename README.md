# Cloud-Native Infrastructure

This repository provides an open, modular, and portable cloud-native infrastructure stack.  
It is designed for cost-effective deployment on European cloud providers (e.g. Hetzner, Scaleway, OVH),  
while remaining fully portable to other providers if required.

## Vision

The project aims to deliver a production-grade reference implementation of Kubernetes-based infrastructure that is:

- High availability and scalable  
- Secure by default  
- Compliant with European GDPR and AI Act principles  
- Built only on open-source components, preferably European-led projects  
- Designed for research, machine learning, AI development, and medical workloads  

## Guiding Principles

- **Portability:** provider-agnostic modules, CNCF alignment  
- **Open Standards:** only open-source, transparent components  
- **European-first:** compliance with GDPR, AI Act, data residency awareness  
- **Security-first:** least privilege, encryption, scanning, and runtime detection  
- **GitOps:** declarative management with continuous reconciliation  
- **Modularity:** easily replace or extend components

## Repository Layout

## Modules created

- core-network: Hetzner private network (10.0.0.0/16).
- hcloud-firewall: Baseline firewall for Kubernetes nodes (SSH + intra-cluster only).
- k8s-control-plane: CP node with static private IP (10.0.0.10).
- k8s-node: Worker nodes (auto IP).
- headscale-server: Dedicated CX22 with minimal firewall (SSH, HTTPS 443, STUN 3478).

## Secrets + automation

- load-secrets.sh script decrypts Hetzner API token and runs tofu plan / apply.
- Added APPLY=true option and ability to target modules.

## First apply

- Headscale server provisioned successfully (SSH verified).
- CP + Workers initially failed because no subnet existed.

## Fix applied

- Added hcloud_network_subnet (10.0.0.0/24) to core-network so servers can attach.
- Now plan includes proper network + subnet before attaching servers.

# Aliases

- build-infra: create everything.
- plan-destroy / apply-destroy: target only servers (safe reset).
- destroy-infra: nuke everything (network, firewalls, servers).



