# Kubernetes Workload Identity Federation

The Kubernetes Workload Identity Federation creates cross-cluster identity federation trust between Kubernetes service accounts running in AWS EKS, Azure AKS, and Goolge GKE. The federation trust allows a Kubernetes service account in all three clusters to access data stored in all three cloud storage services (S3, Azure Storage, and Google Cloud Storage). All in all, a total of 9 cross-cloud trust relationships are created.
