
{{- define "valkey.primary.dnsNames" -}}
{{- $names := list -}}
{{- $names = append $names (include "valkey.objectName" (list . "headless")) -}}
{{- $names = append $names (include "valkey.objectName" (list . "r")) -}}
{{- $names = append $names (include "valkey.objectName" (list . "rw")) -}}
{{ (include "valkey.dnsNames" (list $names .Release.Namespace .Values.service.clusterDomain)) }}
{{- end -}}
