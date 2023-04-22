installCRDs: false

server:
  extraArgs:
    - --insecure
  ingress:
    enabled: ${ argocd_ingress_enabled }
    annotations:
      kubernetes.io/ingress.class: ${ argocd_ingress_class }
      kubernetes.io/tls-acme: "${ argocd_ingress_tls_acme_enabled }"
      nginx.ingress.kubernetes.io/force-ssl-redirect: true
      nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
      nginx.ingress.kubernetes.io/ssl-passthrough: "${ argocd_ingress_ssl_passthrough_enabled }"
    hosts:
      - ${ argocd_server_host }
    tls:
      - secretName: argocd-secret
        hosts:
          - ${ argocd_server_host }

  config:
    url: https://${ argocd_server_host }
    admin.enabled: "true"
    dex.config: |
      connectors:
        - type: github
          id: github
          name: GitHub
          config:
            clientID: ${ argocd_github_client_id }
            clientSecret: ${ argocd_github_client_secret }
            orgs:
              - name: ${ argocd_github_org_name }

  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: ${ eks_iam_argocd_role_arn }

  rbacConfig:
    policy.csv: |
      p, role:team-get-sync-only, applications, get, ${ argocd_project_name }/*, allow
      p, role:team-get-sync-only, applications, sync, ${ argocd_project_name }/*, allow
      g, ${ argocd_github_org_name }:${ github_team }, role:team-get-sync-only
    scopes: '[groups]'
    policy.matchMode: 'glob'