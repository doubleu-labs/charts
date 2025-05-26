
{{- define "lazycnpgcluster.name" -}}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "lazycnpgcluster.fullname" -}}
  {{- if .Values.fullnameOverride -}}
    {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- $name := default .Chart.Name .Values.nameOverride -}}
    {{- if contains $name .Release.Name -}}
      {{- .Release.Name | trunc 63 | trimSuffix "-" -}}
    {{- else -}}
      {{- printf "%s-%s" $name .Release.Name | trunc 63 | trimSuffix "-" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "lazycnpgcluster.labels" -}}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/managed-by: {{ .Release.Name | quote }}
app.kubernetes.io/name: {{ include "lazycnpgcluster.name" . | quote }}
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}"
{{- end -}}

{{- define "lazycnpgcluster.renderHBA" -}}
{{- if and .Values.database.initdb .Values.tls.enabled -}}
- {{ printf "hostssl %s %s all cert" .Values.database.name .Values.database.owner | quote }}
{{- end -}}
{{- range .Values.database.authRecords }}
- {{ . }}
{{- end -}}
{{- end -}}
