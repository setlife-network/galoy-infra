resource "kubernetes_namespace" "smoketest" {
  metadata {
    name = local.smoketest_namespace
  }
}

resource "kubernetes_role" "smoketest" {
  metadata {
    name      = local.smoketest_name
    namespace = kubernetes_namespace.smoketest.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list"]
  }
}

resource "kubernetes_service_account" "smoketest" {
  metadata {
    name      = local.smoketest_name
    namespace = kubernetes_namespace.smoketest.metadata[0].name
  }
}

data "kubernetes_secret" "smoketest_token" {
  metadata {
    name      = kubernetes_service_account.smoketest.default_secret_name
    namespace = kubernetes_namespace.smoketest.metadata[0].name
  }
}

resource "kubernetes_role_binding" "smoketest" {
  metadata {
    name      = local.smoketest_name
    namespace = kubernetes_namespace.smoketest.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.smoketest.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.smoketest_name
    namespace = kubernetes_role.smoketest.metadata[0].namespace
  }
}
