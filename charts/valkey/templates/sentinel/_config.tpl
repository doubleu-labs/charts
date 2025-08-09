
{{- define "valkey.sentinel.dnsNames" -}}
{{- $names := list -}}
{{- $names = append $names (include "valkey.objectName" (list . "sentinel")) -}}
{{ (include "valkey.dnsNames" (list $names .Release.Namespace .Values.service.clusterDomain)) }}
{{- end -}}
