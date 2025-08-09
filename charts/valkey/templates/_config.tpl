
{{- define "valkey.config.ensureReleaseConfigDict" -}}
{{- if not (index .Release "Config") -}}
{{- $_ := set .Release "Config" dict -}}
{{- end -}}
{{- end -}}

{{- define "valkey.config.adminUserName" -}}
{{- $secret := lookup "v1" "Secret" .Release.Namespace (include "valkey.objectName" (list . "user-admin")) -}}
{{- if and $secret $secret.data.username -}}
{{ $secret.data.username | b64dec }}
{{- else -}}
{{- if .Values.auth.adminName -}}
{{ .Values.auth.adminName }}
{{- else -}}
admin
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "valkey.config.adminUserPassword" -}}
{{- $secret := lookup "v1" "Secret" .Release.Namespace (include "valkey.objectName" (list . "user-admin")) -}}
{{- if and $secret $secret.data.password -}}
{{ $secret.data.password | b64dec }}
{{- else -}}
{{- include "valkey.config.ensureReleaseConfigDict" . -}}
{{- if not (index .Release.Config "adminUserPassword") -}}
{{- $_ := set .Release.Config "adminUserPassword" (randAlphaNum 64) -}}
{{- end -}}
{{- index .Release.Config "adminUserPassword" -}}
{{- end -}}
{{- end -}}

{{- define "valkey.config.common" -}}
dir /data
protected-mode no
appendonly yes
{{- end -}}

{{- define "valkey.config.common.tls" }}
{{- $ctx := index . 0 -}}
{{- $secret := index . 1 -}}
{{- $port := index . 2 -}}
{{- if or
  $ctx.Values.tls.certManager.enabled
  (and $ctx.Values.tls.certManager.enabled $ctx.tls.certManager.csiDriver)
  $secret
-}}
port 0
tls-port {{ $port }}
tls-cert-file /run/secrets/valkey/tls/tls.crt
tls-key-file /run/secrets/valkey/tls/tls.key
tls-ca-cert-file /run/secrets/valkey/tls/ca.crt
tls-auth-clients yes
{{- if eq $ctx.Values.architecture "cluster" }}
tls-cluster yes
{{- if ge (int $ctx.Values.cluster.replica.count) 1 }}
tls-replication yes
{{- end }}
{{- end }}
{{- else -}}
port {{ $port }}
{{- end -}}
{{- end -}}

{{- define "valkey.config.acl.auth" -}}
user default off
{{ printf "user %s on #%s ~* &* +@all" (include "valkey.config.adminUserName" .) (include "valkey.config.adminUserPassword" . | sha256sum) }}
{{- end -}}
