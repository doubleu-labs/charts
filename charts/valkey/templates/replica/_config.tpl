
{{- define "valkey.replica.dnsNames" -}}
{{- $names := list -}}
{{- $names = append $names (include "valkey.objectName" (list . "headless")) -}}
{{- $names = append $names (include "valkey.objectName" (list . "r")) -}}
{{ (include "valkey.dnsNames" (list $names .Release.Namespace .Values.service.clusterDomain)) }}
{{- end -}}

{{- define "valkey.config.replicaUserPassword" -}}
{{- $secret := lookup "v1" "Secret" .Release.Namespace (include "valkey.objectName" (list . "user-replica")) -}}
{{- if and $secret $secret.data.password -}}
{{ $secret.data.password | b64dec }}
{{- else -}}
{{- include "valkey.config.ensureReleaseConfigDict" . -}}
{{- if not (index .Release.Config "replicaUserPassword") -}}
{{- $_ := set .Release.Config "replicaUserPassword" (randAlphaNum 64) -}}
{{- end -}}
{{- index .Release.Config "replicaUserPassword" -}}
{{- end -}}
{{- end -}}

{{- define "valkey.replica.secret.conf" -}}
masteruser replicaUser
masterauth {{ include "valkey.config.replicaUserPassword" . }}
{{- end -}}